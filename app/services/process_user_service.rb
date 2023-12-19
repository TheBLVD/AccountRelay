# frozen_string_literal: true

class ProcessUserService < BaseService
  include JsonldHelper
  include Redisable
  include Lockable

  SUBDOMAINS_RATELIMIT = 10
  DISCOVERIES_PER_REQUEST = 400

  # Should be called with confirmed valid JSON
  # and WebFinger-resolved username and domain
  def call(username, domain, json, options = {})
    return if json['inbox'].blank? || unsupported_uri_scheme?(json['id'])

    @options     = options
    @json        = json
    @uri         = @json['id']
    @username    = username
    @domain      = TagManager.instance.normalize_domain(domain)
    @collections = {}

    # The key does not need to be unguessable, it just needs to be somewhat unique
    @options[:request_id] ||= "#{Time.now.utc.to_i}-#{username}@#{domain}"

    @user ||= User.find_remote(@username, @domain)
    @old_public_key     = @user&.public_key
    @old_protocol       = @user&.protocol

    create_user if @user.nil?
    Rails.logger.debug "READY TO CREAT NEW USER>> #{@json}"

    update_user
    Rails.logger.debug "USER FOUND > #{@user}"

    after_protocol_change! if protocol_changed?
    after_key_change! if key_changed? && !@options[:signed_with_known_key]

    @user
  rescue Oj::ParseError
    nil
  end

  private

  def create_user
    @user = User.new
    @user.protocol          = :activitypub
    @user.username          = @username
    @user.domain            = @domain

    set_immediate_protocol_attributes!

    @user.save!
  end

  def update_user
    Rails.logger.debug "UPDATE USER \n\n\n"
    @user.protocol = :activitypub

    set_immediate_protocol_attributes!
    set_fetchable_key!
    set_immediate_attributes!
    set_fetchable_attributes!

    @user.save!
  end

  def set_immediate_protocol_attributes!
    @user.inbox_url               = @json['inbox'] || ''
    @user.outbox_url              = @json['outbox'] || ''
    @user.shared_inbox_url        = (@json['endpoints'].is_a?(Hash) ? @json['endpoints']['sharedInbox'] : @json['sharedInbox']) || ''
    @user.followers_url           = @json['followers'] || ''
    @user.url                     = url || @uri
    @user.uri                     = @uri
    @user.actor_type              = actor_type
    @user.created_at              = @json['published'] if @json['published'].present?
    @user.domain_id               = -99 # Used before AP fetch for acct profile
  end

  def set_immediate_attributes!
    Rails.logger.debug "DOING ATTRIBUTES!!!>>> #{@json['name']} \n #{@json['summary']}"
    @user.featured_collection_url = @json['featured'] || ''
    @user.display_name            = @json['name'] || ''
    @user.note                    = @json['summary'] || ''
    @user.fields                  = property_values || {}
    @user.discoverable            = @json['discoverable'] || false
    @user.avatar_remote_url       = image_url('icon') || ''
  end

  def set_fetchable_key!
    @user.public_key = public_key || ''
  end

  def set_fetchable_attributes!
    @user.following_count   = following_total_items if following_total_items.present?
    @user.followers_count   = followers_total_items if followers_total_items.present?
  end

  def check_links!
    VerifyUserLinksWorker.perform_async(@user.id)
  end

  def actor_type
    if @json['type'].is_a?(Array)
      @json['type'].find { |type| FetchRemoteUserService::SUPPORTED_TYPES.include?(type) }
    else
      @json['type']
    end
  end

  def image_url(key)
    value = first_of_value(@json[key])

    return if value.nil?
    return value['url'] if value.is_a?(Hash)

    image = fetch_resource_without_id_validation(value)
    image['url'] if image
  end

  def public_key
    value = first_of_value(@json['publicKey'])

    return if value.nil?
    return value['publicKeyPem'] if value.is_a?(Hash)

    key = fetch_resource_without_id_validation(value)
    key['publicKeyPem'] if key
  end

  def url
    return if @json['url'].blank?

    url_candidate = url_to_href(@json['url'], 'text/html')

    if unsupported_uri_scheme?(url_candidate) || mismatching_origin?(url_candidate)
      nil
    else
      url_candidate
    end
  end

  def property_values
    return unless @json['attachment'].is_a?(Array)

    as_array(@json['attachment']).select do |attachment|
      attachment['type'] == 'PropertyValue'
    end.map { |attachment| attachment.slice('name', 'value') }
  end

  def mismatching_origin?(url)
    needle   = Addressable::URI.parse(url).host
    haystack = Addressable::URI.parse(@uri).host

    !haystack.casecmp(needle).zero?
  end

  def outbox_total_items
    collection_info('outbox').first
  end

  def following_total_items
    collection_info('following').first
  end

  def followers_total_items
    collection_info('followers').first
  end

  def following_private?
    !collection_info('following').last
  end

  def followers_private?
    !collection_info('followers').last
  end

  def collection_info(type)
    return [nil, nil] if @json[type].blank?
    return @collections[type] if @collections.key?(type)

    collection = fetch_resource_without_id_validation(@json[type])

    total_items = collection.is_a?(Hash) && collection['totalItems'].present? && collection['totalItems'].is_a?(Numeric) ? collection['totalItems'] : nil
    has_first_page = collection.is_a?(Hash) && collection['first'].present?
    @collections[type] = [total_items, has_first_page]
  rescue HTTP::Error, OpenSSL::SSL::SSLError, Mastodon::LengthValidationError
    @collections[type] = [nil, nil]
  end

  def moved_account
    account   = ActivityPub::TagManager.instance.uri_to_resource(@json['movedTo'], User)
    account ||= ActivityPub::FetchRemoteUserService.new.call(@json['movedTo'], id: true, break_on_redirect: true,
                                                                               request_id: @options[:request_id])
    account
  end

  def key_changed?
    !@old_public_key.nil? && @old_public_key != @user.public_key
  end

  def protocol_changed?
    !@old_protocol.nil? && @old_protocol != @user.protocol
  end
end
