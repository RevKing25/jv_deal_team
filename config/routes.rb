Rails.application.routes.draw do
  get 'static_pages/about'
  devise_for :users, controllers: { registrations: 'users/registrations' }

  resources :properties, only: [:index, :new, :create, :show, :edit, :update] do
    member do
      delete 'destroy_image/:image_index', to: 'properties#destroy_image', as: 'destroy_image'
      post 'create_message', to: 'properties#create_message', as: 'create_message'
    end
  end

  resources :messages, only: [:create] do
    member do
      post 'reply', to: 'messages#reply', as: :reply
    end
  end

  resources :interests, only: [:create]

  resources :users, only: [:show, :index] do
  get 'profile', to: 'users#show', on: :member, as: :profile
  get 'messages', to: 'users#messages', on: :member, as: :messages
  post 'create_message', to: 'users#create_message', on: :member, as: 'create_message'
  resources :connections, only: [:create, :update, :index], controller: 'users/connections'
end

  delete '/profile/properties/:id', to: 'users#destroy', as: 'user_property'
  root "static_pages#about"

  namespace :admin do
    get "dashboard", to: "admin#dashboard", as: :dashboard
    delete "users/:id", to: "admin#destroy_user", as: :destroy_user
    delete "properties/:id", to: "admin#destroy_property", as: :destroy_property
  end
end