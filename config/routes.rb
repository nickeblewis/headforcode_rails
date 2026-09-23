Rails.application.routes.draw do
  root "posts#index"
  get "posts", to: "posts#index", as: :posts
  get "posts/:slug", to: "posts#show", as: :post
  get "categories/:slug", to: "posts#category", as: :category_posts
  get "tags", to: "posts#tags_index", as: :tags
  get "tags/:slug", to: "posts#tags", as: :tag_posts
  resources :products
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
