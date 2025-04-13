Rails.application.routes.draw do
  devise_for :users
  get 'users/show'
  get 'users/edit'
  get 'users/update'
  root to: redirect('/home')

  get "home", to: "home#index", as: "home"

  get "products", to: "product#index", as: "products"
  post 'products', to: 'product#create'
  get 'products/new', to: 'product#new', as: 'new_product'
  get 'products/:id', to: 'product#show', as: 'product'
end
