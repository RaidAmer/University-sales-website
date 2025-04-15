# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/home')

  get 'home', to: 'home#index', as: 'home'

  get 'products', to: 'product#index', as: 'products'
  post 'products', to: 'product#create'
  get 'products/new', to: 'product#new', as: 'new_product'
  get 'products/:id', to: 'product#show', as: 'product'

  resource :cart, only: [:show]
  resources :cart_items, only: %i[create destroy]

  resources :checkout_orders, only: [:create]
  resources :payment_transactions, only: %i[new create]
end
