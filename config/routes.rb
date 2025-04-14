Rails.application.routes.draw do
<<<<<<< HEAD
  devise_for :users
  get 'users/show'
  get 'users/edit'
  get 'users/update'
  root to: redirect('/home')
=======
  # Profile
  resource :profile, only: [:show, :edit, :update]
>>>>>>> main

  # Devise (Login/Register)
  devise_for :users, 
             controllers: { 
               registrations: "users/registrations",
               sessions: "users/sessions"   
             },
             path: '', 
             path_names: { 
               sign_in: 'login', 
               sign_out: 'logout', 
               sign_up: 'register' 
             }

  # Root and home
  root to: redirect('/home')
  get "home", to: "home#index", as: "home"

  # Custom flow after registration
  get 'new_user', to: 'users/registrations#new', as: 'new_user'
  post 'users', to: 'users/registrations#create', as: 'users'
  get 'successfully_created_account', to: 'users/registrations#success', as: 'successfully_created_account'

  # Products
  get 'products', to: 'product#index', as: 'products'
  post 'products', to: 'product#create'
  get 'products/new', to: 'product#new', as: 'new_product'
  get 'products/:id', to: 'product#show', as: 'product'
end
