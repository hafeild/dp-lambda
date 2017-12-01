namespace :users do
  desc "Adds a new user to the database."
  task add: :environment do
  end

  desc "Edits an existing user in the database."
  task edit: :environment do
  end

  desc "Makes an existing user an admin."
  task :make_admin, [:username] => [:environment] do |task, args|
    puts args[:username]
    
    if args.has_key? :username
      username = args[:username]
    else
      puts "Enter username: "
      username = STDIN.gets.chomp
    end
    
    begin
      user = User.find_by!(username: username)
      if user.permission_level == "admin"
        puts "This user is already an admin."
      else
        puts user.update!({
          permission_level: "admin", 
          permission_level_granted_by: nil,
          permission_level_granted_on: Time.now
        })
        puts "Success!"
      end
    rescue => e 
      puts e 
    end
  end

  desc "Lists all the users in the database."
  task list: :environment do
    User.all.each do |user|
      puts "User #{user.id}"
      puts "\tName:       #{user.first_name} #{user.last_name}"
      puts "\tUsername:   #{user.username}"
      puts "\tEmail:      #{user.email}"
      puts "\tPer. level  #{user.permission_level}"
      puts "\tGranted on: #{user.permission_level_granted_on}"
      puts "\tGranted by: #{user.permission_level_granted_by.nil? \
        ? "-" \
        : user.permission_granted_by.username}"
      puts "\tCreated on: #{user.created_at}"
      puts
    end
  end

  desc "Finds a user."
  task find: :environment do
    
  end

end
