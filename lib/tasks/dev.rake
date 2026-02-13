unless Rails.env.production?
  namespace :dev do
    desc "Add sample data"
    task sample_data: :environment do
      puts "-- Adding sample data --"

      puts "-- Adding users --"

      names = [
        "alice",
        "bob",
        "carol",
        "dan",
        "ellen",
        "fred",
        "greta",
      ]

      names.each do |name|
        user = User.find_or_create_by(email: "#{name}@example.com") do |user|
          puts "-- Adding user: #{user.email} --"
          user.password = "appdev"
        end
      end

      # Add skills

      100.times do
        name = Names.sample
        email = "#{name}@example.com"
        user = User.find_by(email: email)

        skills = Skills.find_or_create_by(body: Faker::Job.key_skill) do |skills|
          s.user = user
        end
      end

      puts "-- Done --"
    end
  end
end
