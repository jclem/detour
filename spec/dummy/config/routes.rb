Rails.application.routes.draw do
  mount Detour::Engine => "/detour"
  root to: "application#index"
end
