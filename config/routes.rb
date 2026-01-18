Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#app"
  get "/*path", to: "pages#app"

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
    end
  end
end
