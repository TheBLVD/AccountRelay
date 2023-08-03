Rails.application.routes.draw do
  ## ActivityPub requirements
  get '/.well-known/webfinger', to: 'well_known/webfinger#show', as: :webfinger

  ## Relay Inbox
  post '/inbox', to: 'relay_inbox#create', as: :relay_inbox
  get '/actor', to: 'relay_actor#show', as: :relay_actor

  ## API
  namespace :api do
    namespace :v1 do
      resources :accounts, only: %i[create destroy index]
      # foryou
      namespace :foryou do
        resources :users, param: :acct, only: %i[create show] do
          get 'following', on: :member
        end
      end
    end
  end
end
