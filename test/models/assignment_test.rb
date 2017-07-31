require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase

  test "valid with a creator, a unique name, a summary, author, and a description" do 
    assignment = Assignment.new(
      creator: users(:foo),
      name: "A very unique name",
      summary: "a summary",
      description: "a description",
      author: "Foo Bar"
    )
    assert assignment.save, "Couldn't save"
  end


  test "valid with a all fields" do 
    assignment = Assignment.new(
      creator: users(:foo),
      name: "A very unique name",
      summary: "a summary",
      description: "a description",
      author: "Foo Bar",
      thumbnail_url: "http://google.com",
      learning_curve: "low",
      instruction_hours: 4,
      examples: [examples(:one)],
      web_resources: [web_resources(:one)],
      tags: [tags(:one)],
      assignments_related_to: [assignments(:one), assignments(:two)],
      assignment_results: [assignment_results(:two)],
      software: [software(:one)],
      datasets: [datasets(:one)],
      analyses: [analyses(:one)]
    )
    assert assignment.save, "Couldn't save"


    assert assignments(:one).assignments_related_from.exists?(id: assignment.id),
      "Inverse of assignments_related_to not held"
    assert examples(:one).assignments.exists?(id: assignment.id),
      "Example not saved"
    assert web_resources(:one).assignments.exists?(id: assignment.id),
      "Web resource not saved"
    assert tags(:one).assignments.exists?(id: assignment.id), "Tag not saved"
    assert software(:one).assignments.exists?(id: assignment.id), 
      "Software not saved"
    assert datasets(:one).assignments.exists?(id: assignment.id), 
      "Dataset not saved"
    assert analyses(:one).assignments.exists?(id: assignment.id), 
      "Analysis not saved"
    assert assignment_results(:two).assignment == assignment, 
      "Assignment not saved"
  end


  test "must have a creator" do 
    assignment = Assignment.new(
      name: "A very unique name",
      summary: "a summary",
      description: "a description",
      author: "Foo Bar"
    )
    assert_not assignment.save, "Saved without error, but should not have"
  end


  test "must have a name" do
    assignment = Assignment.new(
      creator: users(:foo),
      summary: "a summary",
      description: "a description",
      author: "Foo Bar"
    )
    assert_not assignment.save, "Saved without error, but should not have"

    assignment = Assignment.new(
      creator: users(:foo),
      name: "",
      summary: "a summary",
      description: "a description",
      author: "Foo Bar"
    )
    assert_not assignment.save, "Saved without error, but should not have"
  end



  test "must have a summary" do 
    assignment = Assignment.new(
      creator: users(:foo),
      name: "A very unique name",
      description: "a description",
      author: "Foo Bar"
    )
    assert_not assignment.save, "Saved without error, but should not have"

    assignment = Assignment.new(
      creator: users(:foo),
      name: "A very unique name",
      summary: "",
      description: "a description",
      author: "Foo Bar"
    )
    assert_not assignment.save, "Saved without error, but should not have"
  end



  test "must have a description" do 
    assignment = Assignment.new(
      creator: users(:foo),
      name: "A very unique name",
      summary: "a summary",
      author: "Foo Bar"
    )
    assert_not assignment.save, "Saved without error, but should not have" 

    assignment = Assignment.new(
      creator: users(:foo),
      name: "A very unique name",
      summary: "a summary",
      description: "",
      author: "Foo Bar"
    )
    assert_not assignment.save, "Saved without error, but should not have" 
  end



  test "must have an author" do 
    assignment = Assignment.new(
      creator: users(:foo),
      name: "A very unique name",
      summary: "a summary",
      description: "a description"
    )
    assert_not assignment.save, "Saved without error, but should not have"

    assignment = Assignment.new(
      creator: users(:foo),
      name: "A very unique name",
      summary: "a summary",
      description: "a description",
      author: ""
    )
    assert_not assignment.save, "Saved without error, but should not have" 
  end



  test "name must be unique" do
    assignment = Assignment.new(
      creator: users(:foo),
      name: assignments(:one).name,
      summary: "a summary",
      description: "a description",
      author: "Foo Bar"
    )
    assert_not assignment.save, "Saved without error, but should not have"
  end

  test "destroying an assignment destroys all associated assignment results" do
    assignment_result_id = assignment_results(:one)
    assignment = assignments(:one)

    assignment.destroy

    assert AssignmentResult.find_by(id: assignment_result_id).nil?
  end

end
