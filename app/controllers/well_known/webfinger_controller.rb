# frozen_string_literal: true

module WellKnown
  class WebfingerController < ApiController
    skip_before_action :authenticate_request
    before_action :username_from_resource, only: [:show]
    def show
      @domain = 'acctrelay.moth.social'
      expires_in 3.days, public: true
      Rails.logger.info '>>>>>>WEBFINGER:'
      Rails.logger.info request.fullpath
      Rails.logger.info "GET relay_actor request: #{params.inspect}"
      render json: actor_webfinger, content_type: 'application/jrd+json'
    end

    private

    def actor_webfinger
      {
        "subject": "acct:relay@#{@domain}",
        "aliases": [
          "https://#{@domain}/actor"
        ],
        "links": [
          {
            "rel": 'self',
            "type": 'application/ld+json',
            "href": "https://#{@domain}/actor",
            "profile": 'https://www.w3.org/ns/activitystreams'
          },
          {
            "rel": 'self',
            "type": 'application/activity+json',
            "href": "https://#{@domain}/actor"
          }
        ]
      }
    end

    def username_from_resource
      resource_user    = resource_param
      username, domain = resource_user.split('@')
      return not_found unless username == 'acct:relay' && domain == 'acctrelay.moth.social'
    end

    def resource_param
      params.require(:resource)
    end
  end
end
