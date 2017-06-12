require 'test_helper'

class AssignmentResultTest < ActiveSupport::TestCase

  test "valid with only required fields" do 
    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: assignments(:one),
      course_prefix: "ART",
      course_number: "490",
      course_title: "Senior Thesis I",
      field_of_study: "Visual and Performing Art",
      instructor: "Foo Bar",
      semester: "Summer 2017"
    )
    assert assignment_result.save, "Couldn't save"
  end


  test "valid with all fields" do 
    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: assignments(:one),
      course_prefix: "ART",
      course_number: "490",
      course_title: "Senior Thesis I",
      field_of_study: "Visual and Performing Art",
      instructor: "Foo Bar",
      semester: "Summer 2017",
      project_length_weeks: 5,
      students_given_assignment: 30,
      instruction_hours: 6,
      average_student_score: 2.9,
      outcome_summary: "All is good"
    )
    assert assignment_result.save, "Couldn't save"


    assert assignments(:one).assignment_results.exists?(id: assignment_result.id),
      "Assignment result not associated with assignment"
  end


  test "must have a creator" do 
    assignment_result = AssignmentResult.new(
      assignment: assignments(:one),
      course_prefix: "ART",
      course_number: "490",
      course_title: "Senior Thesis I",
      field_of_study: "Visual and Performing Art",
      instructor: "Foo Bar",
      semester: "Summer 2017"
    )
    assert_not assignment_result.save, "Saved without error, but should not have"
  end


  test "must have an assignment" do
    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      course_prefix: "ART",
      course_number: "490",
      course_title: "Senior Thesis I",
      field_of_study: "Visual and Performing Art",
      instructor: "Foo Bar",
      semester: "Summer 2017"
    )
    assert_not assignment_result.save, "Saved without error, but should not have"

    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: nil,
      course_prefix: "ART",
      course_number: "490",
      course_title: "Senior Thesis I",
      field_of_study: "Visual and Performing Art",
      instructor: "Foo Bar",
      semester: "Summer 2017"
    )
    assert_not assignment_result.save, "Saved without error, but should not have"
  end



  test "must have a course prefix" do 
    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: assignments(:one),
      course_number: "490",
      course_title: "Senior Thesis I",
      field_of_study: "Visual and Performing Art",
      instructor: "Foo Bar",
      semester: "Summer 2017"
    )
    assert_not assignment_result.save, "Saved without error, but should not have"

    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: assignments(:one),
      course_prefix: "",
      course_number: "490",
      course_title: "Senior Thesis I",
      field_of_study: "Visual and Performing Art",
      instructor: "Foo Bar",
      semester: "Summer 2017"
    )
    assert_not assignment_result.save, "Saved without error, but should not have"
  end



  test "must have a course number" do 
    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: assignments(:one),
      course_prefix: "ART",
      course_title: "Senior Thesis I",
      field_of_study: "Visual and Performing Art",
      instructor: "Foo Bar",
      semester: "Summer 2017"
    )
    assert_not assignment_result.save, "Saved without error, but should not have" 

    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: assignments(:one),
      course_prefix: "ART",
      course_number: "",
      course_title: "Senior Thesis I",
      field_of_study: "Visual and Performing Art",
      instructor: "Foo Bar",
      semester: "Summer 2017"
    )
    assert_not assignment_result.save, "Saved without error, but should not have" 
  end



  test "must have a course title" do 
    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: assignments(:one),
      course_prefix: "ART",
      course_number: "490",
      field_of_study: "Visual and Performing Art",
      instructor: "Foo Bar",
      semester: "Summer 2017"
    )
    assert_not assignment_result.save, "Saved without error, but should not have"

    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: assignments(:one),
      course_prefix: "ART",
      course_number: "490",
      course_title: "",
      field_of_study: "Visual and Performing Art",
      instructor: "Foo Bar",
      semester: "Summer 2017"
    )
    assert_not assignment_result.save, "Saved without error, but should not have" 
  end


  test "must have a field of study" do 
    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: assignments(:one),
      course_prefix: "ART",
      course_number: "490",
      course_title: "Senior Thesis I",
      instructor: "Foo Bar",
      semester: "Summer 2017"
    )
    assert_not assignment_result.save, "Saved without error, but should not have"

    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: assignments(:one),
      course_prefix: "ART",
      course_number: "490",
      course_title: "Senior Thesis I",
      field_of_study: "",
      instructor: "Foo Bar",
      semester: "Summer 2017"
    )
    assert_not assignment_result.save, "Saved without error, but should not have" 
  end

  test "must have an instructor" do 
    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: assignments(:one),
      course_prefix: "ART",
      course_number: "490",
      course_title: "Senior Thesis I",
      field_of_study: "Visual and Performing Art",
      semester: "Summer 2017"
    )
    assert_not assignment_result.save, "Saved without error, but should not have"

    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: assignments(:one),
      course_prefix: "ART",
      course_number: "490",
      course_title: "Senior Thesis I",
      field_of_study: "Visual and Performing Art",
      instructor: "",
      semester: "Summer 2017"
    )
    assert_not assignment_result.save, "Saved without error, but should not have" 
  end

  test "must have a semester" do 
    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: assignments(:one),
      course_prefix: "ART",
      course_number: "490",
      course_title: "Senior Thesis I",
      field_of_study: "Visual and Performing Art",
      instructor: "Pat Smith"
    )
    assert_not assignment_result.save, "Saved without error, but should not have"

    assignment_result = AssignmentResult.new(
      creator: users(:foo),
      assignment: assignments(:one),
      course_prefix: "ART",
      course_number: "490",
      course_title: "Senior Thesis I",
      field_of_study: "Visual and Performing Art",
      instructor: "Path Smith",
      semester: ""
    )
    assert_not assignment_result.save, "Saved without error, but should not have" 
  end

end
