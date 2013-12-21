Detour.configure do |config|
  # config.define_user_group :admins do |user|
  #   user.admin?
  # end

  config.grep_dirs = %w[app/**/*.{rb,erb}]

  config.flaggable_types = %w[User Widget]

  config.define_users_group :admin do |admin|
  end

  config.define_users_group :admin1 do |admin|
  end

  config.define_users_group :admin2 do |admin|
  end

  config.define_users_group :admin3 do |admin|
  end

  config.define_users_group :admin4 do |admin|
  end

  config.define_users_group :admin5 do |admin|
  end

  config.define_users_group :admin6 do |admin|
  end

  config.define_users_group :long_group_name_yup do |admin|
  end

  config.define_users_group "Multi-word Group Name" do |admin|
  end
end
