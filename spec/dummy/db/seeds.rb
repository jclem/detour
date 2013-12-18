(1..10).each do |i|
  User.create!(email: "user_#{i}@example.com", name: "User #{i}")
  Detour::Feature.create!(name: "feature_#{i}")
end

User.all.each do |user|
  (1..10).each do |i|
    user.widgets.create! name: "User #{user.id} Widget #{i}"
  end
end
