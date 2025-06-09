Rails.application.routes.draw do
  # Devise routes for authentication (sign_in, sign_up, sign_out, etc.)
  devise_for :users
  
  # Root route
  root to: "home#index"
  
  # Game thoughts management
  resources :game_thoughts, only: [:create, :show, :destroy] do
    member do
      patch :like
      patch :dislike
    end
  end

  # Games detail pages
  resources :games, only: [:show]
  
  # User profiles - using a different path to avoid conflict
  resources :users, only: [:show], path: 'profiles'
  
  # Health check route (if you have one)
  get "up" => "rails/health#show", as: :rails_health_check
end