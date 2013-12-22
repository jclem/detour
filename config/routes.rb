Detour::Engine.routes.draw do
  get  "/flags/:flaggable_type" => "flags#index", as: "flags"
  post "/flags/:flaggable_type" => "flags#update"

  resources :features, only: [:create, :destroy]

  get    "/flag-ins/:feature_name/:flaggable_type"     => "flag_in_flags#index",   as: "flag_in_flags"
  post   "/flag-ins/:feature_name/:flaggable_type"     => "flag_in_flags#create"
  delete "/flag-ins/:feature_name/:flaggable_type/:id" => "flag_in_flags#destroy", as: "flag_in_flag"

  root to: "application#index"
end
