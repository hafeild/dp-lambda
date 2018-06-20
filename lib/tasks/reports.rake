require 'highline/import'

namespace :reports do
  
  def groupBy(array)
    array.inject(Hash.new(0)){|h,k| k.downcase!; h[k.capitalize] += 1;h}
  end

  desc("Basic report braking down assignments and their resources by a given "+
       "tag.\nUsage: reports:assignment_stats_by_tag <tag text>")
  task :assignment_stats_by_tag, [:tag] => [:environment] do |task, args|
    if args.tag.nil?
      print "Enter tag name: "
      tag = STDIN.gets.chomp
    else
      tag = args.tag
    end

    puts "Report for tag \"#{tag}\""

    ## Assignment stats.
    assignments = Tag.find_by(text: tag).assignments.to_a
    numberOfAssignments = assignments.size
    numberOfAssessedAssignments = assignments.select{|x| x.assignment_results.size > 0}.size

    ## Software stats.
    software = assignments.map{|x| x.software.to_a}.flatten
    numberOfDistinctSoftware = software.uniq.size
    avgSoftwarePerAssignment = software.size.to_f / numberOfAssignments

    ## Analyses stats.
    analyses = assignments.map{|x| x.analyses.to_a}.flatten
    numberOfDistinctAnalyses = analyses.uniq.size
    avgAnalysesPerAssignment = analyses.size.to_f / numberOfAssignments

    ## Display info.
    ## Assignments.
    puts "Assignments: #{numberOfAssignments}"
    puts "Assignments assessed: #{numberOfAssessedAssignments}"

    ## Software.
    puts "Software used: #{numberOfDistinctSoftware}"
    puts "Avg. software used per assignment: #{avgSoftwarePerAssignment}"
    ## Group by software and list counts.
    puts "Software breakdown\n========="
    groupBy(software.map{|x| x.name}).each do |name,count|
      puts "   #{name}\t#{count}"
    end
    puts "========="

    ## Analyses.
    puts "Analyses used: #{numberOfDistinctAnalyses}"
    puts "Avg. analyses used per assignment: #{avgAnalysesPerAssignment}"
    ## Group by analyses and list counts.
    puts "Analyses breakdown\n========="
    groupBy(analyses.map{|x| x.name}).each do |name,count|
      puts "   #{name}\t#{count}"
    end
    puts "========="
    
  end

end