Rails.application.routes.draw do

  root 'static_pages#home'
  get 'password_resets/edit'
  get 'signup' => 'users#new'

  resources :users, only: [:create,:update,:edit,:destroy]
  resources :account_activations, only: [:edit]
  resources :email_verifications, only: [:edit]
  resources :password_resets, only: [:new, :create, :edit, :update]
end
