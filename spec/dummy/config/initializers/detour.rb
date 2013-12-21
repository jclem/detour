Detour.configure do |config|
  config.define_user_group :admins do |user|
    user.admin?
  end

  config.define_user_group :vip do |user|
    user.admin?
  end

  config.define_widget_group :foo do |widget|
  end

  config.flaggable_types = %w[User Widget]
  config.grep_dirs       = %w[app/**/*.{rb,erb}]
end
