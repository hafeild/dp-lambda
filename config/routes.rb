Rails.application.routes.draw do
  mount Bootsy::Engine => '/bootsy', as: 'bootsy'

  root    'static_pages#home'
  get     'password_resets/edit'
  get     'signup' => 'users#new'
  get     'login'  => 'sessions#new'
  post    'login'  => 'sessions#create'
  delete  'logout' => 'sessions#destroy'

  resources :examples, except: [:index, :show, :destroy]
  software_example_path = 
  get    'software/:software_id/examples'          => 'examples#index'
  get    'software/:software_id/examples/new'      => 'examples#new'
  get    'software/:software_id/examples/:id/edit' => 'examples#edit'
  post   'software/:software_id/examples/:id'      => 'examples#connect'
  delete 'software/:software_id/examples/:id'      => 'examples#disconnect'


  resources :web_resources
  resources :software
  resources :users, only: [:create,:update,:edit,:destroy]
  resources :account_activations, only: [:edit]
  resources :email_verifications, only: [:edit]
  resources :password_resets, only: [:edit, :new, :create, :update]
  resources :galleries, only: [:create, :update, :destroy]
end
