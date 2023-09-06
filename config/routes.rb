require 'sidekiq/web'

Rails.application.routes.draw do
  ## ActivityPub requirements
  get '/.well-known/webfinger', to: 'well_known/webfinger#show', as: :webfinger

  ## Relay Inbox
  post '/inbox', to: 'relay_inbox#create', as: :relay_inbox
  get '/actor', to: 'relay_actor#show', as: :relay_actor

  # Sidekiq
  mount Sidekiq::Web => '/sq'

  ## API
  namespace :api do
    namespace :v1 do
      # accounts, channels
      resources :accounts, only: %i[create destroy index]
      resources :channels, only: %i[create show destroy index] do
        # Return all channel accounts
        collection do
          get 'accounts'
        end
        # Subscribe/Unsubscribe to channels
        member do
          post :subscribe, constraints: { user_acct: %r{[^/]+} }
          post :unsubscribe, constraints: { user_acct: %r{[^/]+} }
        end
      end

      # foryou
      namespace :foryou do
        resources :users, param: :acct, only: %i[create show index update], constraints: { acct: %r{[^/]+} } do
          resources :following, only: :index, controller: :following_users, constraints: { user_acct: %r{[^/]+} }
        end
      end
    end
  end
end
