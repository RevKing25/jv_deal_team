Rails.application.routes.draw do

  get 'static_pages/about'
  devise_for :users, controllers: { registrations: 'users/registrations' }

  resources :properties, only: [:index, :new, :create, :show, :edit, :update] do
    member do
      delete 'destroy_image/:image_index', to: 'properties#destroy_image', as: 'destroy_image'
    end
  end

  resources :messages, only: [:create] do
    member do
      post 'reply', to: 'messages#reply', as: :reply
    end
  end

  resources :interests, only: [:create]

  resources :users, only: [:show, :index] do  # No standard actions
    get 'profile', to: 'users#show', on: :member, as: :profile
    get 'messages', to: 'users#messages', on: :member, as: :messages
  end

  delete '/profile/properties/:id', to: 'users#destroy', as: 'user_property'
  root "static_pages#about"

  # Admin routes
  namespace :admin do
    get "dashboard", to: "admin#dashboard", as: :dashboard
    delete "users/:id", to: "admin#destroy_user", as: :destroy_user
    delete "properties/:id", to: "admin#destroy_property", as: :destroy_property
  end
end