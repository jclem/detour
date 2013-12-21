Detour.configure do |config|
  # config.define_user_group :admins do |user|
  #   user.admin?
  # end

  config.flaggable_types = %w[User Widget]

  config.define_users_group :admin do |admin|
  end
end
