# frozen_string_literal: true

class ProcessUserService < BaseService
  include JsonLdHelper
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

    with_redis_lock("process_account:#{@uri}") do
      @user            = User.remote.find_by(uri: @uri) if @options[:only_key]
      @user          ||= User.find_remote(@username, @domain)
      @old_public_key     = @user&.public_key
      @old_protocol       = @user&.protocol
      @suspension_changed = false

      if @user.nil?
        with_redis do |redis|
          return nil if redis.pfcount("unique_subdomains_for:#{PublicSuffix.domain(@domain, 
ignore_private: true)}") >= SUBDOMAINS_RATELIMIT

          discoveries = redis.incr("discovery_per_request:#{@options[:request_id]}")
          redis.expire("discovery_per_request:#{@options[:request_id]}", 5.minutes.seconds)
          return nil if discoveries > DISCOVERIES_PER_REQUEST
        end

        create_account
      end

      update_account
      process_tags

      process_duplicate_accounts! if @options[:verified_webfinger]
    end

    after_protocol_change! if protocol_changed?
    after_key_change! if key_changed? && !@options[:signed_with_known_key]
    clear_tombstones! if key_changed?
    after_suspension_change! if suspension_changed?

    unless @options[:only_key] || @user.suspended?
      check_featured_collection! if @user.featured_collection_url.present?
      check_featured_tags_collection! if @json['featuredTags'].present?
      check_links! if @user.fields.any?(&:requires_verification?)
    end

    @user
  rescue Oj::ParseError
    nil
  end

    private

  def create_account
    @user = User.new
    @user.protocol          = :activitypub
    @user.username          = @username
    @user.domain            = @domain
    @user.private_key       = nil
    @user.suspended_at      = domain_block.created_at if auto_suspend?
    @user.suspension_origin = :local if auto_suspend?
    @user.silenced_at       = domain_block.created_at if auto_silence?

    set_immediate_protocol_attributes!

    @user.save!
  end

  def update_account
    @user.last_webfingered_at = Time.now.utc unless @options[:only_key]
    @user.protocol            = :activitypub

    set_suspension!
    set_immediate_protocol_attributes!
    set_fetchable_key! unless @user.suspended? && @user.suspension_origin_local?
    set_immediate_attributes! unless @user.suspended?
    set_fetchable_attributes! unless @options[:only_key] || @user.suspended?

    @user.save_with_optional_media!
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
  end

  def set_immediate_attributes!
    @user.featured_collection_url = @json['featured'] || ''
    @user.devices_url             = @json['devices'] || ''
    @user.display_name            = @json['name'] || ''
    @user.note                    = @json['summary'] || ''
    @user.locked                  = @json['manuallyApprovesFollowers'] || false
    @user.fields                  = property_values || {}
    @user.also_known_as           = as_array(@json['alsoKnownAs'] || []).map { |item| value_or_id(item) }
    @user.discoverable            = @json['discoverable'] || false
    @user.indexable               = @json['indexable'] || false
    @user.memorial                = @json['memorial'] || false
  end

  def set_fetchable_key!
    @user.public_key = public_key || ''
  end

  def set_fetchable_attributes!
    begin
      @user.avatar_remote_url = image_url('icon') || '' unless skip_download?
      @user.avatar = nil if @user.avatar_remote_url.blank?
    rescue Mastodon::UnexpectedResponseError, HTTP::TimeoutError, HTTP::ConnectionError, OpenSSL::SSL::SSLError
      RedownloadAvatarWorker.perform_in(rand(30..600).seconds, @user.id)
    end
    begin
      @user.header_remote_url = image_url('image') || '' unless skip_download?
      @user.header = nil if @user.header_remote_url.blank?
    rescue Mastodon::UnexpectedResponseError, HTTP::TimeoutError, HTTP::ConnectionError, OpenSSL::SSL::SSLError
      RedownloadHeaderWorker.perform_in(rand(30..600).seconds, @user.id)
    end
    @user.statuses_count    = outbox_total_items    if outbox_total_items.present?
    @user.following_count   = following_total_items if following_total_items.present?
    @user.followers_count   = followers_total_items if followers_total_items.present?
    @user.hide_collections  = following_private? || followers_private?
    @user.moved_to_account  = @json['movedTo'].present? ? moved_account : nil
  end

  def set_suspension!
    return if @user.suspended? && @user.suspension_origin_local?

    if @user.suspended? && !@json['suspended']
      @user.unsuspend!
      @suspension_changed = true
    elsif !@user.suspended? && @json['suspended']
      @user.suspend!(origin: :remote)
      @suspension_changed = true
    end
  end

  def after_protocol_change!
    ActivityPub::PostUpgradeWorker.perform_async(@user.domain)
  end

  def after_key_change!
    RefollowWorker.perform_async(@user.id)
  end

  def after_suspension_change!
    if @user.suspended?
      Admin::SuspensionWorker.perform_async(@user.id)
    else
      Admin::UnsuspensionWorker.perform_async(@user.id)
    end
  end

  def check_featured_collection!
    ActivityPub::SynchronizeFeaturedCollectionWorker.perform_async(@user.id, 
{ 'hashtag' => @json['featuredTags'].blank?, 'request_id' => @options[:request_id] })
  end

  def check_featured_tags_collection!
    ActivityPub::SynchronizeFeaturedTagsCollectionWorker.perform_async(@user.id, @json['featuredTags'])
  end

  def check_links!
    VerifyUserLinksWorker.perform_async(@user.id)
  end

  def process_duplicate_accounts!
    return unless User.where(uri: @user.uri).where.not(id: @user.id).exists?

    UserMergingWorker.perform_async(@user.id)
  end

  def actor_type
    if @json['type'].is_a?(Array)
      @json['type'].find { |type| ActivityPub::FetchRemoteUserService::SUPPORTED_TYPES.include?(type) }
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

    as_array(@json['attachment']).select { |attachment|
 attachment['type'] == 'PropertyValue' }.map { |attachment| attachment.slice('name', 'value') }
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

  def skip_download?
    @user.suspended? || domain_block&.reject_media?
  end

  def auto_suspend?
    domain_block&.suspend?
  end

  def auto_silence?
    domain_block&.silence?
  end

  def domain_block
    return @domain_block if defined?(@domain_block)

    @domain_block = DomainBlock.rule_for(@domain)
  end

  def key_changed?
    !@old_public_key.nil? && @old_public_key != @user.public_key
  end

  def suspension_changed?
    @suspension_changed
  end

  def clear_tombstones!
    Tombstone.where(account_id: @user.id).delete_all
  end

  def protocol_changed?
    !@old_protocol.nil? && @old_protocol != @user.protocol
  end

  def process_tags
    return if @json['tag'].blank?

    as_array(@json['tag']).each do |tag|
      process_emoji tag if equals_or_includes?(tag['type'], 'Emoji')
    end
  end

  def process_emoji(tag)
    return if skip_download?
    return if tag['name'].blank? || tag['icon'].blank? || tag['icon']['url'].blank?

    shortcode = tag['name'].delete(':')
    image_url = tag['icon']['url']
    uri       = tag['id']
    updated   = tag['updated']
    emoji     = CustomEmoji.find_by(shortcode:, domain: @user.domain)

    return unless emoji.nil? || image_url != emoji.image_remote_url || (updated && updated >= emoji.updated_at)

    emoji ||= CustomEmoji.new(domain: @user.domain, shortcode:, uri:))
    emoji.image_remote_url = image_url
    emoji.save
  end
end
