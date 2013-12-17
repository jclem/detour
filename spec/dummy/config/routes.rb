Rails.application.routes.draw do

  mount ActiveRecord::Rollout::Engine => "/active_record_rollout"
end
