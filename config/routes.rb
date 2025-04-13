Rails.application.routes.draw do
  root to: redirect('/home')

  get "home", to: "home#index", as: "home"

  get 'categorys/:category_id/products', to: 'product#index', as: 'category_products'
  post 'categorys/:category_id/products', to: 'product#create'
  get 'categorys/:category_id/products/new', to: 'product#new', as: 'new_category_product'
  get 'categorys/:category_id/products/:id', to: 'product#show', as: 'category_product'

  get "categorys", to: "category#index", as: "categorys"
  post 'categorys', to: 'category#create'
  get 'categorys/new', to: 'category#new', as: 'new_category'
  get 'categorys/:id', to: 'category#show', as: 'category'

end
