require 'highline/import'

namespace :v19_01_data_migration do
  
  desc "Makes all users registered, not deleted, and removes at signs from usernames."
  task fix_users: :environment do
    User.all.each do |user|
      user.is_registered = true
      user.deleted = false
      if user.username =~ /@/
        user.username.gsub(/@/, '_')
      end
      user.save!
    end
  end


end
