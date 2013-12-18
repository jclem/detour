Detour::Engine.routes.draw do
  get "/flags/:flaggable_type" => "flags#index", as: "flags"
  root to: "application#index"
end
