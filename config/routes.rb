Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :users, only: :show

      namespace :auth do
        post   "login",    to: "sessions#create"
        post   "refresh",  to: "sessions#refresh"
        delete "logout",   to: "sessions#destroy"
        post   "register", to: "registrations#create"
        post   "confirm",               to: "confirmations#create"
        post   "password/reset",        to: "passwords#create"
        patch  "password/reset/confirm", to: "passwords#confirm"
      end
    end
  end
end
