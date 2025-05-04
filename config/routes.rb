# frozen_string_literal: true

Rails.application.routes.draw do
  get 'messages/index'
  get 'messages/new'
  get 'messages/create'
  get 'messages/show'
  get 'messages/reply'
  get 'notifications/index'
  get 'admin/dashboard', to: 'admin_dashboard#index', as: 'admin_dashboard'
  resource :preferences, only: %i[edit update]
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resource :profile, only: %i[show edit update]

  # config/routes.rb
  namespace :admin do
    resources :users
    resources :products
    resources :categories
  end

  resources :products

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
  root to: redirect('/categories')
  get 'home', to: 'home#index', as: :home

  resource :cart, only: [:show]
  resources :cart_items, only: %i[create destroy] do
    patch :update_quantity, on: :member
  end

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

  get 'categories/:category_id/products/:product_id/reviews', to: 'customer_reviews#index',
                                                              as: 'category_product_reviews'
  get '/categories/:category_id/products/:product_id/reviews/new', to: 'customer_reviews#new',
                                                                   as: 'new_category_product_review'
  post 'categories/:category_id/products/:product_id/reviews', to: 'customer_reviews#create'

  get 'categories', to: 'category#index', as: 'categories'
  post 'categories', to: 'category#create'
  get 'categories/new', to: 'category#new', as: 'new_category'
  get 'categories/:id', to: 'category#show', as: 'category'

  get 'seller_dashboard', to: 'seller_dashboard#index', as: 'seller_dashboard'
  get 'preferences/customize', to: 'preferences#edit', as: 'customize_preferences'
  patch 'preferences/customize', to: 'preferences#update', as: 'preference'
  get 'product_dashboard/:id', to: 'seller_dashboard#show', as: 'product_dashboard'

  get 'admin/users', to: 'admin#users', as: 'custom_admin_users'
  patch 'admin/users/:id/approve', to: 'admin/users#approve', as: 'approve_user'
  patch 'admin/users/:id/deny', to: 'admin/users#deny', as: 'deny_user'

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

  delete 'notifications/clear_all', to: 'notifications#clear_all', as: 'clear_all_notifications'
  post 'notifications/mark_all_as_read', to: 'notifications#mark_all_as_read'
  resources :notifications, only: %i[index destroy]

  patch 'users/:id/theme', to: 'users#update_theme', as: 'update_user_theme'

  resources :messages do
    collection do
      delete :clear_inbox, to: 'messages#clear_inbox', as: :clear_inbox
      delete :clear_sent, to: 'messages#clear_sent', as: :clear_sent
    end
    member do
      post :reply
    end
  end
end
