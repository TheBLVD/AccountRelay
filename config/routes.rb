Rails.application.routes.draw do
  ## API
  namespace :api do
    namespace :v1 do
      resources :accounts, only: %i[create destroy index]
    end
  end
end
