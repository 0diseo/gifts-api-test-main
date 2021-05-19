Rails.application.routes.draw do
  resources :orders
  resources :recipients
  resources :schools
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resource :users, only:[:create]
  post "/login", to: "users#login"
  get "/auto_login", to: "users#auto_login"
  put "/orders/:id/cancel", to: "orders#cancel"
  put "/orders/:id/Ship", to: "orders#Ship"

end
