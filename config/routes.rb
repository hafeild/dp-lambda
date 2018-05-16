Rails.application.routes.draw do
  mount Bootsy::Engine => '/bootsy', as: 'bootsy'

  ## Static pages.
  root    'static_pages#home'
  get     'password_resets/edit'
  get     'signup' => 'users#new'
  get     'login'  => 'sessions#new'
  post    'login'  => 'sessions#create'
  delete  'logout' => 'sessions#destroy'
  get     'users'  => 'users#index'

  ## Verticals.
  resources :software
  resources :datasets
  resources :analyses
  resources :assignments do 
    resources :assignment_results, only: [:create, :new]
  end
  resources :assignment_results, except: [:index, :create, :new]


  ## Resources.
  resources :examples, except: [:index, :destroy]
  resources :web_resources, except: [:index, :destroy]
  resources :tags, except: [:index, :destroy]
  
  verticals = [:software, :dataset, :analysis, :assignment]

  ## Configures all of the routes for interacting with resources attached to
  ## a particular vertical. E.g.,
  ##  get 'software/:software_id/examples' => 'examples#index'
  verticals.each do |vertical|
    base = "#{vertical.to_s.pluralize(2)}/:#{vertical}_id/"

    [:examples, :web_resources, :tags].each do |resource|
      
      resource_base = "#{base}/#{resource}"
      get    resource_base               => "#{resource}#index"
      get    "#{resource_base}/new"      => "#{resource}#new"
      get    "#{resource_base}/:id/edit" => "#{resource}#edit"
      post   "#{resource_base}/:id"      => "#{resource}#connect"
      delete "#{resource_base}/:id"      => "#{resource}#disconnect"
    end
  end
  
  ## Attachments.
  resources :attachments, only: [:index, :create, :destroy]
  (verticals + ['example']).each do |vertical|
    base = "#{vertical.to_s.pluralize(2)}/:#{vertical}_id/"
    resource_base = "#{base}/attachments"
    
    get    resource_base               => "attachments#index"
    # get    "#{resource_base}/new"      => "attachments#new"
    # get    "#{resource_base}/:id/edit" => "attachments#edit"
    post   "#{resource_base}"          => "attachments#create"
    delete "#{resource_base}/:id"      => "attachments#destroy"
    post "#{resource_base}/:id"        => "attachments#update"
    put "#{resource_base}/reorder"    => "attachments#reorder"
  end

  ## Configures all of the routes for connecting two verticals together.
  verticals.each do |vertical|
    base = "#{vertical.to_s.pluralize(2)}/:#{vertical}_id/"

    verticals.each do |vertical2|
      ## Right now, we only want to make connections between assignments and
      ## other verticals, not between arbitrary verticals.
      #next unless vertical == :assignment or vertical2 == :assignment
      next if vertical == :dataset or (vertical2 == :dataset and vertical != :assignment)

      vertical2 = vertical2.to_s.pluralize(2)
      expanded_base = "#{base}/#{vertical2}"
      get    expanded_base               => "#{vertical2}#connect_index"
      get    "#{expanded_base}/:id/edit" => "#{vertical2}#edit"
      post   "#{expanded_base}/:id"      => "#{vertical2}#connect"
      delete "#{expanded_base}/:id"      => "#{vertical2}#disconnect"
    end
  end



  ## Account management.
  resources :users, only: [:create,:update,:edit,:destroy]
  resources :account_activations, only: [:edit]
  resources :email_verifications, only: [:edit]
  resources :password_resets, only: [:edit, :new, :create, :update]
  
  resources :permission_requests, only: [:show, :index, :create, :update]

  ## Search.
  get "search/:vertical" => "search#show"
  

  
end
