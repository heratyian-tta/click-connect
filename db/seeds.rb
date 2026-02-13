# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#   

puts "-- Seeding database --"
emails = [
  "mtheogene@gmail.com",
  "ethompson@example.com",
  "jrodriguez@example.com",
  "schen@example.com",
  "lobrien@example.com",
  "omartinez@example.com",
  "nwilliams@example.com",
  "ikim@example.com",
  "eanderson@example.com",
  "mjohnson@example.com"
]

emails.each do |email|
  puts "-- Adding #{email} --"
  User.find_or_create_by!(email: email) do |user|
    user.password = "appdev"
  end
end

puts "--Done--"
