require 'highline/import'

namespace :v19_01_data_migration do

  desc "Runs all the tasks in this namespace."
  task all: :environment do
    Rake::Task["v19_01_data_migration:copy_sunspot_config"].execute
    Rake::Task["v19_01_data_migration:fix_users"].execute
    Rake::Task["v19_01_data_migration:migrate_assignments"].execute
  end
  
  desc "Copies the updated sunspot configuration file to the solr directory."
  task copy_sunspot_config: :environment do
    source = File.join(Dir.pwd, "sunspot", "conf", "schema.xml")
    target = File.join(Dir.pwd, "solr", "configsets", "sunspot", "conf", "schema.xml")
    FileUtils.cp_r source, target
  end

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

  desc "Migrates old assignments and assignment results to assignment groups and assignments."
  task migrate_assignments: :environment do
    begin
      ActiveRecord::Base.transaction do

        unknown_user = User.find_by(username: "unkown")
        if unknown_user.nil?
          password = SecureRandom.base64(15)
          unknown_user = User.create(
            username: "unkown", 
            email: "info@alice.endicott.edu",
            first_name: "Unknown",
            last_name: "User",
            is_registered: false,
            activated: false,
            password: password,
            password_confirmation: password
          )
        end

        OldAssignment.all.each do |oa|
          puts "Migrating OldAssignment \"#{oa.name}\" (#{oa.id}) to"

          ag = oldAssignmentToAssignmentGroup(oa, unknown_user)
          puts "  AssignmentGroup (#{ag.id})"

          a = oldAssignmentToAssignment(oa, ag, unknown_user)
          puts "  Assignment (#{a.id})"

          oa.assignment_results.each_with_index do |ar, i|
            a2 = addAssignmentResultToAssignment(a, ar, i > 0)
            if i > 0
              puts "  Assignment (#{a2.id})"
            end
          end

          puts "done!\n"
        end


      end
    rescue => e
      puts "There was an error: #{e.message}"
      puts e.backtrace.join("\n")
    end
  end

  private
    def oldAssignmentToAssignmentGroup(oa, author)
      ag = AssignmentGroup.new
      ag.name = oa.name
      ag.summary = oa.summary
      ag.description = oa.description
      ag.creator = oa.creator
      ag.created_at = oa.created_at
      ag.authors << author
      oa.tags.each{|i| ag.tags << i}
      # oa.web_resources.each{|i| ag.web_resources << i}
      ag.save!
      ag
    end

    def oldAssignmentToAssignment(oa, ag, instructor)
      a = Assignment.new
      a.assignment_group = ag
      a.instructors << instructor
      a.creator = oa.creator
      a.created_at = oa.created_at

      a.learning_curve = oa.learning_curve
      a.instruction_hours = oa.instruction_hours

      oa.assignments_related_from.each{|i| a.assignments_related_from << i}
      oa.assignments_related_to.each{|i| a.assignments_related_to << i}
      oa.tags.each{|i| a.tags << i}
      oa.web_resources.each{|i| a.web_resources << i}
      oa.examples.each{|i| a.examples << i}
      oa.software.each{|i| a.software << i}
      oa.analyses.each{|i| a.analyses << i}
      oa.datasets.each{|i| a.datasets << i}
      oa.attachments.each{|i| a.attachments << i}

      ## Some defaults.
      a.course_prefix = "???"
      a.course_number = "???"
      a.course_title = "???"
      a.semester = "???"
      a.field_of_study = "???"

      a.save!
      a
    end

    def addAssignmentResultToAssignment(a, ar, clone=false)
      if clone
        a = a.deep_clone
      end

      a.created_at = ar.created_at

      a.course_prefix = this_or_that_if_empty(ar.course_prefix, "???")
      a.course_number = this_or_that_if_empty(ar.course_number, "???")
      a.course_title = this_or_that_if_empty(ar.course_title, "???")
      a.semester = this_or_that_if_empty(ar.semester, "???")
      a.field_of_study = this_or_that_if_empty(ar.field_of_study, "???")
      a.project_length_weeks = ar.project_length_weeks
      a.students_given_assignment = ar.students_given_assignment
      a.average_student_score = ar.average_student_score
      a.outcome_summary = ar.outcome_summary
      a.instruction_hours = ar.instruction_hours

      a.save!
      a
    end

    def this_or_that_if_empty(arg1, arg2)
      (arg1.nil? || arg1=="") ? arg2 : arg1
    end
end
