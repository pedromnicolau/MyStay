Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "/auth/register", to: "auth#register"
      post "/auth/login", to: "auth#login"
      get "/auth/verify", to: "auth#verify"

      resources :stays do
        member do
          get :contract
        end
      end
      resources :people
      resources :properties
      get "/users/profile", to: "users#profile"
      patch "/users/profile", to: "users#update"
      get "/me", to: "users#me"
      put "/me", to: "users#update_me"
      patch "/me", to: "users#update_me"
    end
  end

  root "pages#app"

  # Evita interceptar blobs do Active Storage pelo fallback do SPA
  get "/*path", to: "pages#app", constraints: ->(req) { !req.path.start_with?("/rails/active_storage") }
end
