Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "/auth/register", to: "auth#register"
      post "/auth/login", to: "auth#login"
      get "/auth/verify", to: "auth#verify"

      post "/tenants/register", to: "tenants#register"
      post "/tenants/login", to: "tenants#login"
      put "/tenant", to: "tenants#update"

      # Public properties endpoint (no authentication required)
      get "/properties/public/showcase", to: "public_properties#showcase"
      get "/properties/public/:id", to: "public_properties#show"

      resources :movements do
        member do
          get :contract
        end
      end
      resources :services do
        member do
          get :contract
        end
      end
      resources :stays do
        member do
          get :contract
        end
      end
      resources :service_types
      resources :people
      resources :properties
      resources :users, except: [ :update ] do
        member do
          patch :update_user
        end
      end
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
