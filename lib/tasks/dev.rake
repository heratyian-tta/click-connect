unless Rails.env.production?
  namespace :dev do
    desc "Drops, creates, migrates, and adds sample data to database"
    task reset: [
      :environment,
      "db:drop",
      "db:create",
      "db:migrate",
      "dev:sample_data",
    ]

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
          user.first_name = name.capitalize
          user.last_name = "Example"
          user.bio = "Hi, I'm #{name.capitalize} and I'm a Sample User!"
        end
      end

      # Add skills (now allowing duplicates)
      10.times do
        name = names.sample  # Fixed: changed Names.sample to names.sample
        email = "#{name}@example.com"
        user = User.find_by(email: email)

        # Skip if user not found (just in case)
        next unless user

        # Use create! instead of find_or_create_by to allow duplicates
        skill = Skill.create( # Fixed: changed Skills to Skill (assuming model name)
          name: Faker::Job.key_skill,

        )

        user_skill = UserSkill.create(
          user: user,
          skill: skill,
        )

        # Optional: print progress every 10 skills
        puts "  Created skill #{skill.id} for #{user.email}" if (skill.id % 10 == 0)
      end

      puts "-- Done --"
    end
  end
end
