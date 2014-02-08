Detour::Engine.routes.draw do
  get  "/flags/:flaggable_type" => "flags#index", as: "flags"
  post "/flags/:flaggable_type" => "flags#update"

  resources :features, only: [:create, :destroy]
  resources :groups, only: [:index, :show, :create, :update, :destroy]

  scope "/:flag_type/:feature_name" do
    get    ":flaggable_type"     => "flaggable_flags#index",   as: "flaggable_flags"
    put    ":flaggable_type"     => "flaggable_flags#update"
    delete ":flaggable_type/:id" => "flaggable_flags#destroy", as: "flaggable_flag"
  end

  root to: "application#index"
end
