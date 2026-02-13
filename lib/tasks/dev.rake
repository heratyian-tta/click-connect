namespace :dev do
  desc "Add sample data"
  task sample_data: :environment do

puts "-- Adding sample data --"

    names = [
      "alice",
      "bob",
      "carol",
      "dan",
      "ellen",
      "fred",
      "greta"
    ]

    puts "-- Adding users --""

    names.each do |name|
      user = User.find_or_create_by!(email: "#{name}@example.com") do |user|
        puts "-- Adding user: #{user.email} --"
      end
        user.password = "appdev")
      end
 
    end
    # Add skills
    # Add projects
    # 
  end

end
