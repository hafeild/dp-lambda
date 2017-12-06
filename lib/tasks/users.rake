require 'highline/import'

namespace :users do
  
  desc "Adds a new user to the database."
  task add: :environment do
    user = User.new
    update_user_from_gets user
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
      
      puts
      puts "Enter values for each of the fields -- leave blank to ignore."
      update_user_from_gets user
      
      
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
          permission_level_granted_by_id: nil,
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
    puts "Not yet implemented."
  end


  private
    def print_user(user)
      puts "User #{user.id}"
      puts "\tName:       #{user.first_name} #{user.last_name}"
      puts "\tUsername:   #{user.username}"
      puts "\tEmail:      #{user.email}"
      puts "\tRole:       #{user.role}"
      puts "\tField:      #{user.field_of_study}"
      puts "\tActivated:  #{user.activated}"
      puts "\tActivated at:#{user.activated_at}"
      puts "\tPer. level  #{user.permission_level}"
      puts "\tGranted on: #{user.permission_level_granted_on}"
      puts "\tGranted by: #{user.permission_level_granted_by.nil? \
        ? "-" \
        : user.permission_granted_by.username}"
      puts "\tCreated on: #{user.created_at}"
      puts
    end
    
    def gets_or_default(default)
      val = STDIN.gets.chomp
      val.size > 0 ? val : default
    end

    def update_user_from_gets(user)
      fields = [:username, :email, :first_name, :last_name, :role,
        :field_of_study, :permission_level, :password, :password_confirmation]
        
      values = {}
      
      fields.each do |field|
        if field == :password or field == :password_confirmation
          data = ask("#{field}: ") {|q| q.echo = false}
        else
          print "#{field}: "
          data = STDIN.gets.chomp
        end
        
        if data.size > 0
          values[field] = data
        end
      end
      
      if values.has_key? :permission_level
        values[:permission_level_granted_on] = Time.now
      end
      
      print "activated? (yes/no/<blank>): "
      data = STDIN.gets.chomp
      if data == "yes" && !user.activated
        user.activate
      elsif data == "no"
        values[:activated] = false
        values[:activated_at] = nil
      end
      
      puts
      puts "Adding these values:\n#{values.map{|k,v| "#{k}: #{v}"}.join("\n")}"
      puts 
           
      user.update!(values)
      
      puts "User successfully updated:"
      puts
      print_user user
    end

end
