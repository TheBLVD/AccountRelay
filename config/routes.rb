Rails.application.routes.draw do
  ## ActivityPub requirements
  get '/.well-known/nodeinfo', to: 'well_known/nodeinfo#index', as: :nodeinfo, defaults: { format: 'json' }
  get '/.well-known/webfinger', to: 'well_known/webfinger#show', as: :webfinger
  ## API
  namespace :api do
    namespace :v1 do
      resources :accounts, only: %i[create destroy index]
    end
  end
end
