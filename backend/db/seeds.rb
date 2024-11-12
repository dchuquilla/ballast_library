# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Create users
User.find_or_create_by(email: "member@example.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
  user.role = APP_ROLES[:member]
end

User.find_or_create_by(email: "librarian@example.com") do |user|
  user.password = "password"
  user.password_confirmation = "password"
  user.role = APP_ROLES[:librarian]
end
