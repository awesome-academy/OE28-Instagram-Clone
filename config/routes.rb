Rails.application.routes.draw do
  devise_for :users, only: :omniauth_callbacks, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'}
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#index"
    
    devise_for :users, controllers: {sessions: "users/sessions",
      registrations: "users/registrations"}, skip: :omniauth_callbacks
    devise_scope :user do
      delete "/logout", to: "users/sessions#destroy"
    end
    get "/feeds", to: "static_pages#index"
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    post "/login", to: "sessions#create"
    
    resources :users do
      resources :posts, only: :index
      member do
        get :following, to: "follows#following"
        get :followers, to: "follows#followers"
        get :bookmarking, to: "bookmarks#index"
      end
    end

    resources :posts do
      member do
        get :likers, to: "likes#index"
      end
      resources :comments, only: %i(create index destroy)   
    end

    namespace :admin do
      resources :users
      resources :posts, except: :new
    end

    resources :comments, only: %i(update destroy)
    resources :relationships, only: %i(update create destroy)
    resources :likes, :bookmarks, only: %i(create destroy)
    resources :searches, only: :index
    resources :notifications, only: %i(index update destroy)

    mount ActionCable.server, at: "/cable"
  end
end
