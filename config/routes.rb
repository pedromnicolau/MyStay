Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "/auth/register", to: "auth#register"
      post "/auth/login", to: "auth#login"
      get "/auth/verify", to: "auth#verify"

      resources :stays
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
  get "/*path", to: "pages#app"
end
