Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    root "static_pages#new"
    
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"

    resources :users
  end
end
