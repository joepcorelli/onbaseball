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
  
  # User profiles and search - using a different path to avoid conflict
  resources :users, only: [:show, :update], path: 'profiles' do
    collection do
      get :search
    end
    # Add follow routes
    member do
      get :following
      get :followers
    end
    resources :follows, only: [:create, :destroy]
  end
  
  # Health check route (if you have one)
  get "up" => "rails/health#show", as: :rails_health_check

  # User search
  get 'search/users', to: 'users#search'
  
  # Notifications
  resources :notifications, only: [:index] do
    member do
      post :mark_as_read
    end
  end
  
  # PWA manifest
  # get 'pwa/manifest', to: 'pwa#manifest', as: :pwa_manifest
end