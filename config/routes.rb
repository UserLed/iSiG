ISeekiGive::Application.routes.draw do

  resources :phone_numbers

  match 'terms-of-service' => 'public#terms_of_service', :as => :terms
  match 'privacy' => 'public#privacy', :as => :privacy

  resources :seekers do
    member do
      get :dashboard
    end
    resources :perspectives, :only => :index, :controller => "seekers/perspectives" do
      collection do
        match :schools
        match :majors
        match :cities
        match :functions
        match :skills
      end
    end
    resources :sessions, :only => :index, :controller => "seekers/sessions" do
      collection do
        match :personal_details
        match :manage_requests
        match :session_request_reject
        match :inbox
        get :inbox
        match 'messages/new' => 'seekers/sessions#new_message'
        match 'messages/:uid'  => 'seekers/sessions#show_message', :as => "show_message"
        resources :billing_settings, :except => [:index, :destroy]
      end
    end
  end

  resources :givers do
    member do
      get :dashboard
      get :public_profile
      post :create_schedule
    end
    resources :perspectives, :only => :index, :controller => "givers/perspectives" do
      collection do
        match :game_1
        match :game_2
        match :game_3
        match ':experience_id/experience' =>  'givers/perspectives#experience', :as => "game_experience"
        match ':education_id/education' =>  'givers/perspectives#education', :as => "game_education"
      end
    end
    resources :sessions, :only => :index, :controller => "givers/sessions" do
      collection do

        match :personal_details
        match :manage_requests
        match :inbox
        get :inbox
        match 'messages/new' => 'givers/sessions#new_message'
        match 'messages/:uid'  => 'givers/sessions#show_message', :as => "show_message"
        post :time_slot_save
        match :session_request_accept
        match :session_request_reject
        post :reject_schedule
        get  :get_schedule_data
        post :accept_schedule
        resources :billing_settings, :except => [:index, :destroy]
      end
    end
  end

  resources :educations
  resources :skills
  resources :experiences
  
  resources :password_resets
  
  resources :sessions

  match '/popup' => 'users#popup', :as => :popup
  match 'login' => 'sessions#new', :as => :login
  match 'logout' => 'sessions#destroy', :as => :logout

  match 'signup' => 'public#signup', :as => :signup
  
  match "oauth/:provider/callback" => "oauths#callback"
  match "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider

  post 'email_checker' => 'users#email_checker', :as => 'email_checker'

  get "oauths/oauth"
  get "oauths/callback"

  resources :connections, :only => [:new] do
    collection do
      get :callback
    end
  end

  resources :users do
    member do
      get  :activate
      get :resend_confirmation
    end
  end

  root :to => 'public#index'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
end
