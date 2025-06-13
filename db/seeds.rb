# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding users and tasks..."

users_data = [
  {
    email: "user1@example.com",
    password: "password123",
    password_confirmation: "password123",
    tasks: [
      Task.new(title: "Task One of user1", description: "Description One of user1", completed: true),
      Task.new(title: "Task Two of user1", description: "Description Two of user1", completed: false),
      Task.new(title: "Task Three of user1", description: "Description Three of user1", completed: false)
    ]
  },
  {
    email: "user2@example.com",
    password: "password123",
    password_confirmation: "password123",
    tasks: [
      Task.new(title: "Task One of user2", description: "Description One of user2", completed: true),
      Task.new(title: "Task Two of user2", description: "Description Two of user2", completed: true)
    ]
  }
]

users_data.each do |user_attrs|
  User.find_or_create_by(email: user_attrs[:email]) do |user|
    user.assign_attributes(user_attrs)
    user.tasks = user_attrs[:tasks]
  end
end

puts "Users and tasks seeded!"
