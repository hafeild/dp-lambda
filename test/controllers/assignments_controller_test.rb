require "test_helper"

class AssignmentsControllerTest < ActionController::TestCase

  ##############################################################################
  ## Testing create

  test "should fail when creating an assignment without being logging in" do
    assignment_group = assignment_groups(:one)
    assert_no_difference "Assignment.count", "Assignment created" do
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "x",
          course_title: "x", field_of_study: "x", semester: "x" 
        } 
      }
      assert_redirected_to login_path, @response.body
    end
  end

  test "should create assignment and link to assignment group page" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    assert_difference "assignment_group.assignments.count", 1, 
      "Assignment not added to assignment group" do
      assert_difference "Assignment.count", 1, "Assignment not created" do
        post :create, params: { assignment_group_id: assignment_group.id, 
          assignment: { 
            instructors: users(:foo).id, course_prefix: "x", course_number: "y",
            course_title: "z", field_of_study: "a", semester: "b" 
          } 
        }
        assignment = Assignment.last
        assert_redirected_to assignment_group_assignment_path(assignment.assignment_group, assignment), @response.body

        assignment_group.reload
        assert assignment_group.assignments.exists?(id: assignment.id)
        assert assignment.instructors.first.id == users(:foo).id
        assert assignment.course_prefix == "x"
        assert assignment.course_number == "y"
        assert assignment.course_title == "z"
        assert assignment.field_of_study == "a"
        assert assignment.semester == "b"
        assert assignment.creator.id == users(:foo).id
      end
    end
  end

  test "should break when creating an assignment result without required fields" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    assert_no_difference "Assignment.count", "Assignment created" do

      ## Missing instructors.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          course_prefix: "x", course_number: "y",
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Missing instructor not validated."

      ## Missing course_prefix.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_number: "y",
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Missing course_prefix not validated."

      ## Missing course_number.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x",
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Missing course_number not validated."

      ## Missing course_title.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Missing course_title not validated."

      ## Missing field_of_study.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "z", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Missing field_of_study not validated."

      ## Missing semester.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "z", field_of_study: "a" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Missing semester not validated."
    end
  end

  test "should break when creating an assignment result with blank required fields" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    assert_no_difference "Assignment.count", "Assignment created" do

      ## Empty instructors.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: "", course_prefix: "x", course_number: "y",
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Empty instructor not validated."

      ## Empty course_prefix.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "", course_number: "y",
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Empty course_prefix not validated."

      ## Empty course_number.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "",
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Empty course_number not validated."

      ## Empty course_title.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Empty course_title not validated."

      ## Empty field_of_study.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "z", field_of_study: "", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Empty field_of_study not validated."

      ## Empty semester.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "z", field_of_study: "a", semester: "" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Empty semester not validated."
    end
  end


  test "should break when creating an assignment result with a too long course prefix, number, or title" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    assert_no_difference "Assignment.count", "Assignment created" do
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x"*4, course_number: "y",
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Too-long course_prefix field not validated."

      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y"*4,
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Too-long course_number field not validated."

      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "z"*201, field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Too-long course_title field not validated."
    end
  end


  test "should break when creating an assignment result with a too long field of study" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    assert_no_difference "Assignment.count", "Assignment created" do
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "z", field_of_study: "a"*201, semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Too-long field_of_study field not validated."
    end
  end

  test "should break when creating an assignment result with a too long semester" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    assert_no_difference "Assignment.count", "Assignment created" do
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "z", field_of_study: "a", semester: "b"*16 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Too-long semester field not validated."
    end
  end


  ## JSON response errors.

  test "should return must be logged in json error" do
    ## Not logged in.
    assignment_group = assignment_groups(:one)
    @request.env['CONTENT_TYPE'] = 'application/json'
    post :create, format: :json, params: { 
      assignment_group_id: assignment_group.id, assignment: { 
        instructors: users(:foo).id, course_prefix: "x", course_number: "y",
        course_title: "z", field_of_study: "a", semester: "b" 
      } 
    }
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] = "You must be logged in to modify content."
  end

  test "should return success json on basic create" do
    ## Logged in, successful create.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    post :create, format: :json, params: { 
      assignment_group_id: assignment_group.id, assignment: { 
        instructors: users(:foo).id.to_s, course_prefix: "x", course_number: "y",
        course_title: "z", field_of_study: "a", semester: "b" 
      } 
    }
    result = JSON.parse(@response.body)
    assert result['success'], @response.body
    assert result['redirect'] == assignment_group_assignment_path(assignment_group, Assignment.last), @response.body
  end

  test "should return missing params json error message" do
    ## Missing required field.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    post :create, format: :json, params: { 
      assignment_group_id: assignment_group.id, assignment: { 
        course_prefix: "x", course_number: "y",
        course_title: "z", field_of_study: "a", semester: "b" 
      } 
    }
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error']=="You must provide a course prefix, number, and title, a field of study, a semester, and one or more instructors.",
      result['error']
  end

  test "should return required params not supplied json error" do
    ## No assignment parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    post :create, format: :json, params: {assignment_group_id: assignment_group.id}
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "Required parameters not supplied."
  end

  test "should return saving assignment json error" do
    ## Too long of a course_prefix.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    post :create, format: :json, params: { 
      assignment_group_id: assignment_group.id, assignment: { 
        instructors: users(:foo).id.to_s, course_prefix: "x"*4, course_number: "y",
        course_title: "z", field_of_study: "a", semester: "b" 
      } 
    }
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "There was an error saving the assignment "+
      "entry: Validation failed: Course prefix is too long (maximum is 3 "+
      "characters).", result['error']
  end


  ##############################################################################


  ##############################################################################
  ## Testing updating an assignment_result.

  test "shouldn't update assignment entry when not logged in" do 
    assignment = assignments(:one)
    assignment_group = assignment.assignment_group

    patch :update, params: { assignment_group_id: assignment_group.id,
      id: assignment.id, 
      assignment: { 
        instructors: users(:foo).id, course_prefix: "x", course_number: "y",
        course_title: "z", field_of_study: "a", semester: "b"
      } 
    }

    assert_redirected_to login_path, @response.body
    assignment.reload
    assert assignment.instructors.size == 2, "Instructors updated."
    assert assignment.instructors.exists?(id: users(:foo).id)
    assert assignment.instructors.exists?(id: users(:bar).id),
      "Instructors updated."
    assert users(:foo).instructed_assignments.exists?(id: assignment.id)
    assert users(:bar).instructed_assignments.exists?(id: assignment.id),
      "Instructors reciprocated."
    assert_not assignment.course_prefix == "x", "course_prefix updated"
    assert_not assignment.course_number == "y", "course_number updated"
    assert_not assignment.course_title == "z", "course_title updated"
    assert_not assignment.field_of_study == "a", "field_of_study updated"
    assert_not assignment.semester == "b", "semester updated"
  end

  test "shouldn't update assignment entry then redirect to edit page on invalid parameter" do 
    log_in_as users(:foo)
    assignment = assignments(:one)
    assignment_group = assignment.assignment_group

    patch :update, params: { assignment_group_id: assignment_group.id,
      id: assignment.id, 
      assignment: { 
        instructors: users(:foo).id, course_prefix: "x"*4, course_number: "y",
        course_title: "z", field_of_study: "a", semester: "b"
      } 
    }

    assert_redirected_to edit_assignment_group_assignment_path(assignment_group, assignment), @response.body
    assignment.reload
    assert assignment.instructors.size == 2, "Instructors updated."
    assert assignment.instructors.exists?(id: users(:foo).id)
    assert assignment.instructors.exists?(id: users(:bar).id),
      "Instructors updated."
    assert users(:foo).instructed_assignments.exists?(id: assignment.id)
    assert users(:bar).instructed_assignments.exists?(id: assignment.id),
      "Instructors reciprocated."
    assert_not assignment.course_prefix == "x", "course_prefix updated"
    assert_not assignment.course_number == "y", "course_number updated"
    assert_not assignment.course_title == "z", "course_title updated"
    assert_not assignment.field_of_study == "a", "field_of_study updated"
    assert_not assignment.semester == "b", "semester updated"
  end

  test "should update the assignment and redirect to its assignment group page" do
    log_in_as users(:foo)
    assignment = assignments(:one)
    assignment_group = assignment.assignment_group
    patch :update, params: { id: assignment.id, 
      assignment_group_id: assignment_group.id,
      assignment: { 
        instructors: users(:foo).id, course_prefix: "x", course_number: "y",
        course_title: "z", field_of_study: "a", semester: "b"
      } 
    }
    assert_redirected_to assignment_path(assignment), 
      @response.body
      assignment.reload
    assert assignment.instructors.size == 1, "Instructors not updated."
    assert assignment.instructors.exists?(id: users(:foo).id),
      "Instructors not updated."
    assert users(:foo).instructed_assignments.exists?(id: assignment.id)
    assert_not users(:bar).instructed_assignments.exists?(id: assignment.id),
      "Instructors not reciprocated."
    assert assignment.course_prefix == "x", "course_prefix not updated"
    assert assignment.course_number == "y", "course_number not updated"
    assert assignment.course_title == "z", "course_title not updated"
    assert assignment.field_of_study == "a", "field_of_study not updated"
    assert assignment.semester == "b", "semester not updated"
  end


  ## JSON response on update tests.

  test "should return unknown assignment json error on update" do
    ## No assignment parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    assignment_group = assignment_groups(:one)
    log_in_as users(:foo)
    patch :update, format: :json, params: {
      assignment_group_id: assignment_group.id, id: 0, assignment: { 
      course_title: "z", field_of_study: "a", semester: "b" }}
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "No assignment with the specified id exists."
  end

  test "should return success json message with redirect to assignment "+
      " page on update" do
    ## No assignment parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    assignment = assignments(:one)
    assignment_group = assignment.assignment_group

    patch :update, format: :json, params: { 
      assignment_group_id: assignment_group.id, id:assignment.id,
      assignment: {
        instructors: users(:foo).id.to_s, course_prefix: "x", course_number: "y",
        course_title: "z", field_of_study: "a", semester: "b"
      }
    }

    result = JSON.parse(@response.body)
    assert result['success'], @response.body
    assert result['redirect'] == assignment_path(assignment.id), @response.body
  end

  test "should update multiple instructors." do
    ## No assignment parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    assignment = assignments(:two)
    assignment_group = assignment.assignment_group

    patch :update, format: :json, params: { 
      assignment_group_id: assignment_group.id, id:assignment.id,
      assignment: {
        instructors: [users(:foo).id,users(:bar).id].join(","), 
        course_prefix: "x", course_number: "y",
        course_title: "z", field_of_study: "a", semester: "b"
      }
    }

    result = JSON.parse(@response.body)
    assert result['success'], @response.body
    assert result['redirect'] == assignment_path(assignment.id), @response.body

    assignment.reload
    assert assignment.instructors.size == 2, "Instructors not updated."
    assert assignment.instructors.exists?(id: users(:foo).id)
    assert assignment.instructors.exists?(id: users(:bar).id),
      "Instructors not updated."
    assert users(:foo).instructed_assignments.exists?(id: assignment.id)
    assert users(:bar).instructed_assignments.exists?(id: assignment.id),
      "Instructors not reciprocated."
    assert assignment.course_prefix == "x", "course_prefix not updated"
    assert assignment.course_number == "y", "course_number not updated"
    assert assignment.course_title == "z", "course_title not updated"
    assert assignment.field_of_study == "a", "field_of_study not updated"
    assert assignment.semester == "b", "semester not updated"
  end

  test "should return error updating assignment json message on update" do
    ## Invalid course_prefix parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    assignment = assignments(:one)
    assignment_group = assignment.assignment_group

    patch :update, format: :json, params: { 
      assignment_group_id: assignment_group.id, id: assignment.id, 
      assignment: { 
        instructors: users(:foo).id.to_s, course_prefix: "x"*4, course_number: "y",
        course_title: "z", field_of_study: "a", semester: "b"
      } 
    }
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "There was an error updating the assignment entry."
    # assert_redirected_to edit_assignment_path(assignment), @response.body

    assignment.reload
    assert assignment.instructors.size == 2, "Instructors updated."
    assert assignment.instructors.exists?(id: users(:foo).id)
    assert assignment.instructors.exists?(id: users(:bar).id),
      "Instructors updated."
    assert users(:foo).instructed_assignments.exists?(id: assignment.id)
    assert users(:bar).instructed_assignments.exists?(id: assignment.id),
      "Instructors reciprocated."
    assert_not assignment.course_prefix == "x", "course_prefix updated"
    assert_not assignment.course_number == "y", "course_number updated"
    assert_not assignment.course_title == "z", "course_title updated"
    assert_not assignment.field_of_study == "a", "field_of_study updated"
    assert_not assignment.semester == "b", "semester updated"

  end

  ##############################################################################

  ##############################################################################
  ## Testing deleting an assignment_result.

  test "should delete the assignment and redirect to its assignment group page" do
    log_in_as users(:foo)
    assignment = assignments(:six)
    assignment_group = assignment.assignment_group
    soloWebResource_AssignmentSix = web_resources(:soloWebResource_AssignmentSix)
    mutliWebResource2 = web_resources(:mutliWebResource2)
    soloTag_AssignmentSix = tags(:soloTag_AssignmentSix)
    multiTag1 = tags(:multiTag1)

    assert_difference "assignment_group.assignments.count", -1, 
      "Assignment not removed from assignment group" do
    assert_difference "Assignment.count", -1, "Assignment not deleted" do
    assert_difference "Tag.count", -1, "Solo tag not removed." do
    assert_difference "WebResource.count", -1, "Multi web resource removed." do
      delete :destroy, params: { assignment_group_id: assignment_group.id, 
        id: assignment.id }
      assert_redirected_to assignment_group_path(assignment_group), @response.body
      assignment_group.reload

      assert_not assignment_group.assignments.exists?(id: assignment.id)
      assert_not Tag.find_by(id: soloTag_AssignmentSix), "Solo tag not removed."
      assert Tag.find_by(id: multiTag1), "Multi tag removed."
      assert_not WebResource.find_by(id: soloWebResource_AssignmentSix), "Solo web resource not removed."
      assert WebResource.find_by(id: mutliWebResource2), "Multi web resource removed."
      
      ## Test connections.
      assert_not examples(:soloExample_AssignmentSix).assignments.exists?(id: assignment.id)
      assert_not examples(:multiExample1).assignments.exists?(id: assignment.id)
      assert_not analyses(:soloAnalysis_AssignmentSix).assignments.exists?(id: assignment.id)
      assert_not analyses(:multiAnalysis1).assignments.exists?(id: assignment.id)
      assert_not software(:soloSoftware_AssignmentSix).assignments.exists?(id: assignment.id)
      assert_not software(:multiSoftware1).assignments.exists?(id: assignment.id)
      assert_not datasets(:soloDataset_AssignmentSix).assignments.exists?(id: assignment.id)
      assert_not datasets(:multiDataset1).assignments.exists?(id: assignment.id)
    end
    end
    end
    end
  end


  ##############################################################################


  ##############################################################################
  ## Connection tests.

  test "should connect an assignment to an assignment" do
    log_in_as users(:foo)
    assignment1 = assignments(:two)
    assignment2 = assignments(:three)

    assert_difference "assignment1.assignments_related_to.count", 1, "Assignment not linked" do
    assert_difference "assignment2.assignments_related_from.count", 1, "Assignment not linked" do
      post :connect, params: {assignment_group_id: assignment1.assignment_group.id, assignment_id: assignment1.id, id: assignment2.id}
      assert_redirected_to assignment_path(assignment1), @response.body
      assignment1.reload
      assignment2.reload
      assert assignment1.assignments_related_to.exists?(id: assignment2.id), 
        "Assignment not in list of assignments related to"
      assert assignment2.assignments_related_from.exists?(id: assignment1.id), 
        "Assignment not in list of assignments related from"
    end
    end

  end

  ## End connection tests.
  ##############################################################################

  ##############################################################################
  ## Removing a connection tests.

  test "should remove the connection between an assignment and assignment" do
    log_in_as users(:foo)
    assignment1 = assignments(:one)
    assignment2 = assignments(:two)

    assert assignment1.assignments_related_to.exists?(id: assignment2.id), 
      "Assignment not in list of assignments related to"
    assert assignment2.assignments_related_from.exists?(id: assignment1.id), 
      "Assignment not in list of assignments related from"

    assert_difference "assignment1.assignments_related_to.count", -1, "Assignment not unlinked" do
    assert_difference "assignment2.assignments_related_from.count", -1, "Assignment not unlinked" do
      delete :disconnect, params: {assignment_group_id: assignment1.assignment_group.id, assignment_id: assignment1.id, id: assignment2.id}
      assert_redirected_to assignment_path(assignment1), @response.body
      assignment1.reload
      assignment2.reload
      assert_not assignment1.assignments_related_to.exists?(id: assignment2.id), 
        "Assignment not removed from list of assignments related to"
      assert_not assignment2.assignments_related_from.exists?(id: assignment1.id), 
        "Assignment not removed from list of assignments related from"
    end
    end

  end

  ## End connection removal tests.
  ##############################################################################

end