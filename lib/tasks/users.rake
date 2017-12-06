namespace :users do
  desc "Adds a new user to the database."
  task add: :environment do
  end

  desc "Edits an existing user in the database."
  task :edit, [:username] => [:environment] do |task, args|
    if args.username.nil?
      print "Enter username: "
      username = STDIN.gets.chomp
    else
      username = args.username
    end
    
    begin
      user = User.find_by!(username: username)
      
      puts "Current values"
      puts "==============="
      print_user user
      
      puts "Enter values for each of the fields -- leave blank to ignore."
      print "Username: "
      username = gets.chomp
      print "Email: "
      email = gets.chomp
      print "First name: "
      first_name = gets.chomp
      print "Last name: "
      last_name = gets.chomp
      print "Role (faculty/student): "
      role = gets.chomp
      print "Field of study: "
      field_of_study = gets.chomp
      print "Activate? (yes/no): "
      activate = gets.chomp
      print "Permission level (viewer/editor/admin): "
      permission_level = gets.chomp
      
      
    rescue => e
      puts e
    end
    
  end

  desc "Makes an existing user an admin."
  task :make_admin, [:username] => [:environment] do |task, args|
    if args.username.nil?
      print "Enter username: "
      username = STDIN.gets.chomp
    else
      username = args.username
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
      print_user user
    end
  end

  desc "Finds a user."
  task find: :environment do
    
  end


  private
    def print_user(user)
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
    
    def gets_or_default(default)
      val = gets.chomp
      val.size > 0 ? val : default
    end
end
