require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase


  test "valid with required fields" do 
    assignment = Assignment.new(
      creator: users(:foo),
      instructors: [users(:bar)],
      course_prefix: "CSC",
      course_number: "101",
      course_title: "Intro to Computer Science",
      field_of_study: "Computer Science",
      semester: "Fall 2018",
      assignment_group: assignment_groups(:one)
    )
    assert assignment.save, "Couldn't save"
  end


  test "valid with all fields" do 
    assignment = Assignment.new(
      ## Required fields.
      creator: users(:foo),
      instructors: [users(:bar)],
      course_prefix: "CSC",
      course_number: "101",
      course_title: "Intro to Computer Science",
      field_of_study: "Computer Science",
      semester: "Fall 2018",
      assignment_group: assignment_groups(:one),
      ## Optional fields.
      notes: "some notes....",
      learning_curve: "low",
      instruction_hours: 4,
      outcome_summary: "very good",
      project_length_weeks: 2,
      students_given_assignment: 25,
      average_student_score: 5.3,
      examples: [examples(:one)],
      web_resources: [web_resources(:one)],
      tags: [tags(:one)],
      assignments_related_to: [assignments(:one), assignments(:two)],
      software: [software(:one)],
      datasets: [datasets(:one)],
      analyses: [analyses(:one)]
      ## TODO Once attachments tests are created, add in attachments here.
    )
    assert assignment.save, "Couldn't save"

    assert assignments(:one).assignments_related_from.exists?(id: assignment.id),
      "Inverse of assignments_related_to not held"
    assert assignments(:two).assignments_related_from.exists?(id: assignment.id),
      "Inverse of assignments_related_to not held"
    assert examples(:one).assignments.exists?(id: assignment.id),
      "Example not reciprocated"
    assert web_resources(:one).assignments.exists?(id: assignment.id),
      "Web resource not reciprocated"
    assert tags(:one).assignments.exists?(id: assignment.id), "Tag not saved"
    assert software(:one).assignments.exists?(id: assignment.id), 
      "Software not reciprocated"
    assert datasets(:one).assignments.exists?(id: assignment.id), 
      "Dataset not reciprocated"
    assert analyses(:one).assignments.exists?(id: assignment.id), 
      "Analysis not reciprocated"
    assert assignment_groups(:one).assignments.exists?(id: assignment.id),
      "Assignment not connected to assignment group"
  end


  test "must have all required fields" do 
    ## Missing creator.
    assignment = Assignment.new(
      instructors: [users(:bar)],
      course_prefix: "CSC",
      course_number: "101",
      course_title: "Intro to Computer Science",
      field_of_study: "Computer Science",
      semester: "Fall 2018",
      assignment_group: assignment_groups(:one)
    )
    assert_not assignment.save, "Saved with missing creator"

    ## Missing instructors.
    assignment = Assignment.new(
      creator: users(:foo),
      course_prefix: "CSC",
      course_number: "101",
      course_title: "Intro to Computer Science",
      field_of_study: "Computer Science",
      semester: "Fall 2018",
      assignment_group: assignment_groups(:one)
    )
    assert_not assignment.save, "Saved with missing instructor"

    ## Missing course_prefix.
    assignment = Assignment.new(
      creator: users(:foo),
      instructors: [users(:bar)],
      course_number: "101",
      course_title: "Intro to Computer Science",
      field_of_study: "Computer Science",
      semester: "Fall 2018",
      assignment_group: assignment_groups(:one)
    )
    assert_not assignment.save, "Saved with missing course_prefix"

    ## Missing course_number.
    assignment = Assignment.new(
      creator: users(:foo),
      instructors: [users(:bar)],
      course_prefix: "CSC",
      course_title: "Intro to Computer Science",
      field_of_study: "Computer Science",
      semester: "Fall 2018",
      assignment_group: assignment_groups(:one)
    )
    assert_not assignment.save, "Saved with missing course_number"

    ## Missing course_title.
    assignment = Assignment.new(
      creator: users(:foo),
      instructors: [users(:bar)],
      course_prefix: "CSC",
      course_number: "101",
      field_of_study: "Computer Science",
      semester: "Fall 2018",
      assignment_group: assignment_groups(:one)
    )
    assert_not assignment.save, "Saved with missing course_title"

    ## Missing field_of-study.
    assignment = Assignment.new(
      creator: users(:foo),
      instructors: [users(:bar)],
      course_prefix: "CSC",
      course_number: "101",
      course_title: "Intro to Computer Science",
      semester: "Fall 2018",
      assignment_group: assignment_groups(:one)
    )
    assert_not assignment.save, "Saved with missing field_of-study"

    ## Missing semester.
    assignment = Assignment.new(
      creator: users(:foo),
      instructors: [users(:bar)],
      course_prefix: "CSC",
      course_number: "101",
      course_title: "Intro to Computer Science",
      field_of_study: "Computer Science",
      assignment_group: assignment_groups(:one)
    )
    assert_not assignment.save, "Saved with missing semester"

    ## Missing assignment_group.
    assignment = Assignment.new(
      creator: users(:foo),
      instructors: [users(:bar)],
      course_prefix: "CSC",
      course_number: "101",
      course_title: "Intro to Computer Science",
      field_of_study: "Computer Science",
      semester: "Fall 2018"
    )
    assert_not assignment.save, "Saved with missing assignment_group"

  end


  test "all required fields must be non-empty" do 
    ## Empty creator.
    assignment = Assignment.new(
      creator: nil,
      instructors: [users(:bar)],
      course_prefix: "CSC",
      course_number: "101",
      course_title: "Intro to Computer Science",
      field_of_study: "Computer Science",
      semester: "Fall 2018",
      assignment_group: assignment_groups(:one)
    )
    assert_not assignment.save, "Saved with empty creator"

    ## Empty instructors.
    assignment = Assignment.new(
      creator: users(:foo),
      instructors: [],
      course_prefix: "CSC",
      course_number: "101",
      course_title: "Intro to Computer Science",
      field_of_study: "Computer Science",
      semester: "Fall 2018",
      assignment_group: assignment_groups(:one)
    )
    assert_not assignment.save, "Saved with empty instructor"

    ## Empty course_prefix.
    assignment = Assignment.new(
      creator: users(:foo),
      instructors: [users(:bar)],
      course_prefix: "",
      course_number: "101",
      course_title: "Intro to Computer Science",
      field_of_study: "Computer Science",
      semester: "Fall 2018",
      assignment_group: assignment_groups(:one)
    )
    assert_not assignment.save, "Saved with empty course_prefix"

    ## Empty course_number.
    assignment = Assignment.new(
      creator: users(:foo),
      instructors: [users(:bar)],
      course_prefix: "CSC",
      course_number: "",
      course_title: "Intro to Computer Science",
      field_of_study: "Computer Science",
      semester: "Fall 2018",
      assignment_group: assignment_groups(:one)
    )
    assert_not assignment.save, "Saved with empty course_number"

    ## Empty course_title.
    assignment = Assignment.new(
      creator: users(:foo),
      instructors: [users(:bar)],
      course_prefix: "CSC",
      course_number: "101",
      course_title: "",
      field_of_study: "Computer Science",
      semester: "Fall 2018",
      assignment_group: assignment_groups(:one)
    )
    assert_not assignment.save, "Saved with empty course_title"

    ## Empty field_of-study.
    assignment = Assignment.new(
      creator: users(:foo),
      instructors: [users(:bar)],
      course_prefix: "CSC",
      course_number: "101",
      course_title: "Intro to Computer Science",
      field_of_study: "",
      semester: "Fall 2018",
      assignment_group: assignment_groups(:one)
    )
    assert_not assignment.save, "Saved with empty field_of-study"

    ## Empty semester.
    assignment = Assignment.new(
      creator: users(:foo),
      instructors: [users(:bar)],
      course_prefix: "CSC",
      course_number: "101",
      course_title: "Intro to Computer Science",
      field_of_study: "Computer Science",
      semester: "",
      assignment_group: assignment_groups(:one)
    )
    assert_not assignment.save, "Saved with empty semester"

    ## Empty assignment_group.
    assignment = Assignment.new(
      creator: users(:foo),
      instructors: [users(:bar)],
      course_prefix: "CSC",
      course_number: "101",
      course_title: "Intro to Computer Science",
      field_of_study: "Computer Science",
      semester: "Fall 2018",
      assignment_group: nil
    )
    assert_not assignment.save, "Saved with empty assignment_group"

  end

  ## This test trigger a seg fault that is not the fault of the model as far
  ## as I can tell. With a new version of ruby (e.g., 1.3.5), it should be
  ## fixed.
  # test "deep_clone should create a deep clone of all fields and associations" do
  #   assignment = Assignment.new(
  #     ## Required fields.
  #     creator: users(:foo),
  #     instructors: [users(:bar)],
  #     course_prefix: "CSC",
  #     course_number: "101",
  #     course_title: "Intro to Computer Science",
  #     field_of_study: "Computer Science",
  #     semester: "Fall 2018",
  #     assignment_group: assignment_groups(:one),
  #     ## Optional fields.
  #     notes: "some notes....",
  #     learning_curve: "low",
  #     instruction_hours: 4,
  #     outcome_summary: "very good",
  #     project_length_weeks: 2,
  #     students_given_assignment: 25,
  #     average_student_score: 5.3,
  #     examples: [examples(:one)],
  #     web_resources: [web_resources(:one)],
  #     tags: [tags(:one)],
  #     assignments_related_to: [assignments(:one), assignments(:two)],
  #     software: [software(:one)],
  #     datasets: [datasets(:one)],
  #     analyses: [analyses(:one)]
  #     ## TODO Once attachments tests are created, add in attachments here.
  #   )
  #   assert assignment.save, "Couldn't save"

  #   assert assignments(:one).assignments_related_from.exists?(id: assignment.id),
  #     "Inverse of assignments_related_to not held"
  #   assert assignments(:two).assignments_related_from.exists?(id: assignment.id),
  #     "Inverse of assignments_related_to not held"
  #   assert examples(:one).assignments.exists?(id: assignment.id),
  #     "Example not reciprocated"
  #   assert web_resources(:one).assignments.exists?(id: assignment.id),
  #     "Web resource not reciprocated"
  #   assert tags(:one).assignments.exists?(id: assignment.id), "Tag not saved"
  #   assert software(:one).assignments.exists?(id: assignment.id), 
  #     "Software not reciprocated"
  #   assert datasets(:one).assignments.exists?(id: assignment.id), 
  #     "Dataset not reciprocated"
  #   assert analyses(:one).assignments.exists?(id: assignment.id), 
  #     "Analysis not reciprocated"
  #   assert assignment_groups(:one).assignments.exists?(id: assignment.id),
  #     "Assignment not connected to assignment group"


  #   assignment2 = assignment.deep_clone
  #   assert assignment2.save!, "Couldn't save clone"

  #   assert assignment2.creator == assignment.creator, "Creator not cloned"
  #   assert assignment2.course_prefix == assignment.course_prefix, 
  #     "course_prefix not cloned"
  #   assert assignment2.course_number == assignment.course_number, 
  #     "course_number not cloned"
  #   assert assignment2.course_title == assignment.course_title, 
  #     "course_title not cloned"
  #   assert assignment2.field_of_study == assignment.field_of_study, 
  #     "field_of_study not cloned"
  #   assert assignment2.semester == assignment.semester, 
  #     "semester not cloned"
  #   assert assignment2.notes == assignment.notes, "notes not cloned"
  #   assert assignment2.assignment_group == assignment.assignment_group,
  #     "assignment_group not cloned"
  #   assert assignment2.learning_curve == assignment.learning_curve, 
  #     "learning_curve not cloned"
  #   assert assignment2.instruction_hours == assignment.instruction_hours, 
  #     "instruction_hours not cloned"
  #   assert assignment2.outcome_summary == assignment.outcome_summary, 
  #     "outcome_summary not cloned"
  #   assert assignment2.project_length_weeks == assignment.project_length_weeks,
  #     "project_length_weeks not cloned"
  #   assert assignment2.students_given_assignment == assignment.students_given_assignment, 
  #     "students_given_assignment not cloned"
  #   assert assignment2.average_student_score == assignment.average_student_score,
  #       "average_student_score not cloned"

  #   assert assignment2.instructors.exists?(id: users(:bar).id),
  #     "Instructors not cloned"
  #   assert assignment2.software.exists?(id: software(:one).id),
  #     "Software not cloned"
  #   assert assignment2.datasets.exists?(id: datasets(:one).id),
  #     "Datasets not cloned"
  #   assert assignment2.analyses.exists?(id: analyses(:one).id),
  #     "Analyses not cloned"
  #   assert assignment2.examples.exists?(id: examples(:one).id),
  #     "Examples not cloned"
  #   assert assignment2.assignments_related_to.exists?(id: assignments(:one).id),
  #     "Related assignment not cloned"
  #   assert assignment2.assignments_related_to.exists?(id: assignments(:two).id),
  #     "Related assignment not cloned"
  #   assert assignment2.tags.exists?(id: tags(:one).id),
  #     "Tags not cloned"
  #   assert assignment2.web_resources.exists?(id: web_resources(:one).id),
  #     "Web resources not cloned"

  #   assert assignments(:one).assignments_related_from.exists?(id: assignment2.id),
  #     "Inverse of assignments_related_to not held"
  #   assert assignments(:two).assignments_related_from.exists?(id: assignment2.id),
  #     "Inverse of assignments_related_to not held"
  #   assert examples(:one).assignments.exists?(id: assignment2.id),
  #     "Example not reciprocated"
  #   assert web_resources(:one).assignments.exists?(id: assignment2.id),
  #     "Web resource not reciprocated"
  #   assert tags(:one).assignments.exists?(id: assignmen2t.id), "Tag not saved"
  #   assert software(:one).assignments.exists?(id: assignment2.id), 
  #     "Software not reciprocated"
  #   assert datasets(:one).assignments.exists?(id: assignmen2t.id), 
  #     "Dataset not reciprocated"
  #   assert analyses(:one).assignments.exists?(id: assignment2.id), 
  #     "Analysis not reciprocated"
  #   assert assignment_groups(:one).assignments.exists?(id: assignment2.id),
  #     "Assignment not connected to assignment group"
  # end
end
