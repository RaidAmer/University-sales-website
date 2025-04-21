# frozen_string_literal: true

Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resource :profile, only: %i[show edit update]

  # config/routes.rb
  namespace :admin do
    resources :users
  end

  # Devise (Login/Register)
  devise_for :users,
             controllers: {
               registrations: 'users/registrations',
               sessions:      'users/sessions'
             },
             path:        '',
             path_names:  {
               sign_in:  'login',
               sign_out: 'logout',
               sign_up:  'register'
             }

  # Root and home
  root to: redirect('/home')
  get 'home', to: 'home#index', as: 'home'

  resource :cart, only: [:show]
  resources :cart_items, only: %i[create destroy]

  resources :checkout_orders, only: %i[index show create] do
    member do
      patch :delivered
      patch :cancel
    end
  end
  resources :payment_transactions, only: %i[new create]

  # Custom flow after registration
  get 'new_user', to: 'users/registrations#new', as: 'new_user'
  post 'users', to: 'users/registrations#create', as: 'users'
  get 'successfully_created_account', to: 'users/registrations#success', as: 'successfully_created_account'

  get 'categories/:category_id/products', to: 'product#index', as: 'category_products'
  post 'categories/:category_id/products', to: 'product#create'
  get 'categories/:category_id/products/new', to: 'product#new', as: 'new_category_product'
  get 'categories/:category_id/products/:id', to: 'product#show', as: 'category_product'

  get 'categories', to: 'category#index', as: 'categories'
  post 'categories', to: 'category#create'
  get 'categories/new', to: 'category#new', as: 'new_category'
  get 'categories/:id', to: 'category#show', as: 'category'


  get 'seller_dashboard', to: 'seller_dashboard#index', as: 'seller_dashboard'
  get 'product_dashboard/:id', to: 'seller_dashboard#show', as: 'product_dashboard'
  

  get 'admin/users', to: 'admin#users', as: 'custom_admin_users'
  patch 'admin/users/:id/approve', to: 'admin#approve', as: 'approve_user'

  get 'events', to: 'events#index', as: 'events'
  post 'events', to: 'events#create'
  get 'events/new', to: 'events#new', as: 'new_event'
  get 'events/:id/edit', to: 'events#edit', as: 'edit_event'
  patch 'events/:id', to: 'events#update'
  get 'events/:id', to: 'events#show', as: 'event'
  delete 'events/:id', to: 'events#destroy'
  post 'events/:id/register', to: 'events#register', as: 'register_event'
  resources :events do
    post 'register', on: :member
  end
  post 'events/:id/unregister', to: 'events#unregister', as: 'unregister_event'

  # get 'checkout_orders_page', to: 'checkout_orders#index', as: 'checkout_orders_index'
  # get 'checkout_orders/:id', to: 'checkout_orders#show', as: 'checkout_order'
end
