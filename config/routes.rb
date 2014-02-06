Detour::Engine.routes.draw do
  get  "/flags/:flaggable_type" => "flags#index", as: "flags"
  post "/flags/:flaggable_type" => "flags#update"

  resources :features, only: [:create, :destroy]
  resources :groups, only: [:index, :show, :create, :update, :destroy]

  %w[flag-ins opt-outs].each do |flag_type|
    scope "/#{flag_type}/:feature_name" do
      get    ":flaggable_type"     => "flaggable_flags#index",   as: "#{flag_type.underscore.singularize}_flags"
      put    ":flaggable_type"     => "flaggable_flags#update"
      delete ":flaggable_type/:id" => "flaggable_flags#destroy", as: "#{flag_type.underscore.singularize}_flag"
    end
  end

  root to: "application#index"
end
