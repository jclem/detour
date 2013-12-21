Detour::Engine.routes.draw do
  get  "/flags/:flaggable_type" => "flags#index", as: "flags"
  post "/flags/:flaggable_type" => "flags#update"

  resources :features, only: [:create]

  root to: "application#index"
end
