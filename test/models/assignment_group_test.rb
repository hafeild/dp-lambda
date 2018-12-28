require 'test_helper'

class AssignmentGroupTest < ActiveSupport::TestCase

  test "valid with a creator, a unique name, a summary, author, and a description" do 
    assignment_group = AssignmentGroup.new(
      creator: users(:foo),
      name: "A very unique name",
      summary: "a summary",
      description: "a description",
      authors: [users(:foo), users(:bar)]
    )
    assert assignment_group.save, "Couldn't save"
    assert assignment_group.authors.exists?(id: users(:foo).id), 
      "First author not saved."
    assert assignment_group.authors.exists?(id: users(:bar).id), 
      "Second author not saved."
    assert users(:foo).authored_assignment_groups.exists?(id: assignment_group.id), 
      "First author not recipricated."
    assert users(:bar).authored_assignment_groups.exists?(id: assignment_group.id), 
      "Second author not recipricated."  
    assert users(:foo).created_assignment_groups.exists?(id: assignment_group.id), 
      "Creator not recipricated."
  end


  test "valid with all fields" do 
    assignment_group = AssignmentGroup.new(
      creator: users(:bar),
      name: "A very unique name",
      summary: "a summary",
      description: "a description",
      authors: [users(:foo)],
      web_resources: [web_resources(:one)],
      tags: [tags(:one)],
      assignments: [assignments(:five)]
    )
    assert assignment_group.save, "Couldn't save"
    assignment_group.reload

    assert assignment_group.name == "A very unique name", "Name not saved."
    assert assignment_group.summary == "a summary", "Summary not saved."
    assert assignment_group.description == "a description", "Description not saved."

    assert users(:bar).created_assignment_groups.exists?(id: assignment_group.id), 
      "Creator not recipricated."
    assert users(:foo).authored_assignment_groups.exists?(id: assignment_group.id), 
      "First author not recipricated."
    assert web_resources(:one).assignment_groups.exists?(id: assignment_group.id),
      "Web resource not recipricated"
    assert tags(:one).assignment_groups.exists?(id: assignment_group.id), 
      "Tag not recipricated"
    assert assignments(:five).assignment_group == assignment_group, 
      "Assignment not recipricated"
  end


  test "must have a creator" do 
    assignment_group = AssignmentGroup.new(
      name: "A very unique name",
      summary: "a summary",
      description: "a description",
      authors: [users(:foo)]
    )
    assert_not assignment_group.save, 
      "Saved without validating presence of creator."
  end


  test "must have a name" do
    assignment_group = AssignmentGroup.new(
      creator: users(:foo),
      summary: "a summary",
      description: "a description",
      authors: [users(:foo)]
    )
    assert_not assignment_group.save, 
      "Saved without validating presence of name."

    assignment_group = AssignmentGroup.new(
      creator: users(:foo),
      name: "",
      summary: "a summary",
      description: "a description",
      authors: [users(:foo)]
    )
    assert_not assignment_group.save, 
      "Saved without validating length of name."
  end



  test "must have a summary" do 
    assignment_group = AssignmentGroup.new(
      creator: users(:foo),
      name: "a name",
      description: "a description",
      authors: [users(:foo)]
    )
    assert_not assignment_group.save, 
      "Saved without validating presence of summary."

    assignment_group = AssignmentGroup.new(
      creator: users(:foo),
      name: "a name",
      summary: "",
      description: "a description",
      authors: [users(:foo)]
    )
    assert_not assignment_group.save, 
      "Saved without validating length of summary."
  end



  test "must have one or more authors" do 
    assignment_group = AssignmentGroup.new(
      creator: users(:foo),
      name: "a name",
      summary: "a summary",
      description: "a description",
    )
    assert_not assignment_group.save, 
      "Saved without validating presence of authors."

    assignment_group = AssignmentGroup.new(
      creator: users(:foo),
      name: "a name",
      summary: "a summary",
      description: "a description",
      authors: []
    )
    assert_not assignment_group.save, 
      "Saved without validating length of authors."
  end


  test "name must be unique" do
    assignment_group = AssignmentGroup.new(
      creator: users(:foo),
      name: assignment_groups(:one).name,
      summary: "a summary",
      description: "a description",
      authors: [users(:foo)]
    )
    assert_not assignment_group.save, 
      "Saved without validating name uniqueness."
  end

  test "destroying an assignment_group destroys all associated assignments" do
    assignment_group = assignment_groups(:one)    
    assignment_ids = assignment_group.assignments.map{|a| a.id}

    assert_difference 'Assignment.count', -(assignment_ids.size), "Assignments not removed" do
      assignment_group.destroy
      assignment_ids.each do |id|
        assert Assignment.find_by(id: id).nil?, "Assignment not destroyed."
      end
    end
  end

end
