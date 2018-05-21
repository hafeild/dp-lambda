require 'highline/import'

namespace :db do
  
  desc "Lists invalid database entries."
  task list_invalid: :environment do
    Example.all.each do |example|
      unless example.valid?
        puts "Example #{example.id}: #{example.title}"
      end
    end
  end

  desc "Makes all invalid examples valid by putting in dummy values for the summary and creator."
  task make_examples_valid: :environment do
    Example.all.each do |example|
      unless example.valid?
        if example.summary.nil? or example.summary.size == 0
          example.summary = "Please update me."
        end

        if example.creator.nil?
          example.creator = User.first
        end

        example.save!
      end
    end
  end
end