Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resource :profile, only: [:show, :edit, :update]

# config/routes.rb
namespace :admin do
  resources :users
end

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

  get 'categories/:category_id/products', to: 'product#index', as: 'category_products'
  post 'categories/:category_id/products', to: 'product#create'
  get 'categories/:category_id/products/new', to: 'product#new', as: 'new_category_product'
  get 'categories/:category_id/products/:id', to: 'product#show', as: 'category_product'

  get "categories", to: "category#index", as: "categories"
  post 'categories', to: 'category#create'
  get 'categories/new', to: 'category#new', as: 'new_category'
  get 'categories/:id', to: 'category#show', as: 'category'
  
  get 'admin/users', to: 'admin#users', as: 'custom_admin_users'
  patch 'admin/users/:id/approve', to: 'admin#approve', as: 'approve_user'
  


end
