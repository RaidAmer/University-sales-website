Rails.application.routes.draw do
  root to: redirect('/home')

  get "home", to: "home#index", as: "home"

  get 'categories/:category_id/products', to: 'product#index', as: 'category_products'
  post 'categories/:category_id/products', to: 'product#create'
  get 'categories/:category_id/products/new', to: 'product#new', as: 'new_category_product'
  get 'categories/:category_id/products/:id', to: 'product#show', as: 'category_product'

  get "categories", to: "category#index", as: "categories"
  post 'categories', to: 'category#create'
  get 'categories/new', to: 'category#new', as: 'new_category'
  get 'categories/:id', to: 'category#show', as: 'category'

end
