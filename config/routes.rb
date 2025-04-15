# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/home')

  get 'home', to: 'home#index', as: 'home'

  get 'events', to: 'events#index', as: 'events'
  post 'events', to: 'events#create'
  get 'events/new', to: 'events#new', as: 'new_event'
  get 'events/:id', to: 'events#show', as: 'event'

  get 'products', to: 'product#index', as: 'products'
  post 'products', to: 'product#create'
  get 'products/new', to: 'product#new', as: 'new_product'
  get 'products/:id', to: 'product#show', as: 'product'
end
