# frozen_string_literal: true

module UserFinderConcern
  extend ActiveSupport::Concern

  class_methods do
    def find_local!(username)
      find_local(username) || raise(ActiveRecord::RecordNotFound)
    end

    def find_remote!(username, domain)
      find_remote(username, domain) || raise(ActiveRecord::RecordNotFound)
    end

    # TODO: EnsureKeys
    # TODO: actor_type
    def representative
      actor = User.find(-99)
      actor.update!(username: 'mammoth.internal') if actor.username.include?(':')
      actor
    rescue ActiveRecord::RecordNotFound
      # User.create!(id: -99, actor_type: 'Application', locked: true, username: 'mammoth.internal')
      User.create!(id: -99, username: 'mammoth.internal', domain_id: -99)
    end

    def find_remote(username, domain)
      UserFinder.new(username, domain).user
    end
  end

  class UserFinder
    attr_reader :username, :domain

    def initialize(username, domain)
      @username = username
      @domain = domain
    end

    def user
      scoped_users.order(id: :asc).take
    end

    private

    def scoped_users
      User.unscoped.tap do |scope|
        scope.merge! with_usernames
        scope.merge! matching_username
        scope.merge! matching_domain
      end
    end

    def with_usernames
      User.where.not(User.arel_table[:username].lower.eq '')
    end

    def matching_username
      User.where(User.arel_table[:username].lower.eq username.to_s.downcase)
    end

    def matching_domain
      User.where(User.arel_table[:domain].lower.eq(domain.nil? ? nil : domain.to_s.downcase))
    end
  end
end
