Detour::Engine.routes.draw do
  get  "/flags/:flaggable_type" => "flags#index", as: "flags"
  post "/flags/:flaggable_type" => "flags#update"

  resources :features, only: [:create, :destroy]

  get "/flag-ins/:feature_name/:flaggable_type" => "flag_in_flags#index", as: "flag_in_flags"

  root to: "application#index"
end
