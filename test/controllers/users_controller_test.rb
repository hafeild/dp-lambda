require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  ##############################################################################
  ## Testing create
  
  test "should create a new user" do
    assert_difference "User.count", 1, "User not created" do
      post :create, params: { user: { 
        username: "x",
        email: "x@mail.org",
        role: "student",
        first_name: "X",
        last_name: "Y",
        field_of_study: "XYZ",
        password: "12345678",
        password_confirmation: "12345678",
        permission_level: "viewer"
      } }
      assert_redirected_to root_path, @response.body
      user = User.find_by(username: "x")
      assert_not user.nil?, "New user doesn't exist."
      assert user.permission_level == "viewer", 
        "Permission level saved incorrectly."
    end
  end
  
  test "should fail because insufficient arguments" do
    assert_no_difference "User.count", "User created" do
      post :create, params: { user: { 
        username: "x",
        role: "student",
        first_name: "X",
        last_name: "Y",
        field_of_study: "XYZ",
        password: "12345678",
        permission_level: "viewer"
      } }
    end
  end
  
  
  test "should create a user with viewer permissions" do
    assert_difference "User.count", 1, "User not created" do
      post :create, params: { user: { 
        username: "x",
        email: "x@mail.org",
        role: "student",
        first_name: "X",
        last_name: "Y",
        field_of_study: "XYZ",
        password: "12345678",
        password_confirmation: "12345678",
        permission_level: "what"
      } }
      assert_redirected_to root_path, @response.body
      user = User.find_by(username: "x")
      assert_not user.nil?, "New user doesn't exist."
      assert user.permission_level == "viewer", 
        "Permission level saved incorrectly."
    end
  end
  
  
  test "should create a user with viewer permissions and a permission request" do
    assert_difference "User.count", 1, "User not created" do
    assert_difference "PermissionRequest.count", 1, "Permission request not created" do
      post :create, params: { user: { 
        username: "x",
        email: "x@mail.org",
        role: "student",
        first_name: "X",
        last_name: "Y",
        field_of_study: "XYZ",
        password: "12345678",
        password_confirmation: "12345678",
        permission_level: "admin"
      } }
      assert_redirected_to root_path, @response.body
      user = User.find_by(username: "x")
      assert_not user.nil?, "New user doesn't exist."
      assert user.permission_level == "viewer", 
        "Permission level saved incorrectly."
      permission_request = PermissionRequest.find_by(user: user)
      assert_not permission_request.nil?
      assert permission_request.level_requested = "admin"
    end
    end
  end
  
  ##############################################################################
  ## Testing create_stub
  test "should create a new user stub" do
    log_in_as users(:bar)
    assert_difference "User.count", 1, "User not created" do
      post :create_stub, format: :json, params: { user: { 
        email: "x@mail.org",
        first_name: "X",
        last_name: "Y"
      } }
      result = JSON.parse(@response.body)
      assert result['success'], @response.body
      assert result['data'].has_key?('user_stub'),
        "Missing user_stub key: #{@response.body}"

      user_stub = result['data']['user_stub']

      assert user_stub.has_key?('json'), 
        "Missing data.user_stub.json: #{@response.body}"
      assert user_stub['json']['id'] == User.last.id, 
        "Wrong user id (expected #{User.last.id}): #{@response.body}"
      assert user_stub['json']['first_name'] == User.last.first_name,
        "Wrong first_name (expected #{User.last.first_name}): #{@response.body}"
      assert user_stub['json']['last_name'] == User.last.last_name,
        "Wrong last_name (expected #{User.last.last_name}): #{@response.body}"
      assert user_stub['json']['email'] == User.last.email,
        "Wrong email (expected #{User.last.email}): #{@response.body}"
      assert user_stub.has_key?('html'),
        "Missing data.user_stub.html: #{@response.body}"
      # assert false, user_stub['html']
      num_spans = user_stub['html'].scan(/<span\b/).size
      assert num_spans == 2,
        "Missing expected number of span tags (got #{num_spans}, expected 2) "+
        "in data.html: #{user_stub['html']}"
    end
  end
  
  test "create_stub should fail because insufficient arguments" do
    log_in_as users(:bar)

    ## Missing first_name.
    assert_no_difference "User.count", "User created" do
      post :create_stub, format: :json, params: { user: { 
        email: "x@mail.org",
        last_name: "Y"
      } }
      result = JSON.parse(@response.body)
      assert_not result['success'], "Should have found an error: #{@response.body}"
      assert result['error'] == "There was an error! Validation failed: First name can't be blank",
        "Error message incorrect: #{result['error']}."
    end

    ## Missing last_name.
    assert_no_difference "User.count", "User created" do
      post :create_stub, format: :json, params: { user: { 
        email: "x@mail.org",
        first_name: "X"
      } }
      result = JSON.parse(@response.body)
      assert_not result['success'], "Should have found an error: #{@response.body}"
      assert result['error'] == "There was an error! Validation failed: Last name can't be blank",
        "Error message incorrect: #{result['error']}."
    end
  
    ## Missing email.
    assert_no_difference "User.count", "User created" do
      post :create_stub, format: :json, params: { user: { 
        first_name: "X",
        last_name: "Y"
      } }
      result = JSON.parse(@response.body)
      assert_not result['success'], "Should have found an error: #{@response.body}"
      assert result['error'] == "There was an error! Validation failed: "+
        "Email can't be blank, Email is invalid",
        "Error message incorrect: #{result['error']}"
    end
  end
  
  test "shouldn't create a user stub if not logged in" do
    assert_no_difference "User.count", "User created" do
      post :create_stub, format: :json, params: { user: { 
        email: "x@mail.org",
        first_name: "X",
        last_name: "Y"
      } }
      result = JSON.parse(@response.body)
      assert_not result['success'], "Should have found an error: #{@response.body}"
      assert result['error'] == "This action requires that you be logged in.",
        "Error message incorrect: #{result['error']}"
    end
  end

  ##############################################################################
  ## Testing update
  
  test "should delete user" do
    user = users(:foo)
    log_in_as user
    post :destroy, params: { id: user.id }
    user.reload
    assert_not user.username.nil?, "Username nill"
    assert user.email == "", "Email not blank"
    assert user.first_name == nil, "First name not nill"
    assert user.last_name == nil, "Last name not nill"
    assert user.role == nil, "Role not nill"
    assert user.field_of_study == nil, "Field of study not nill"
    assert user.password_digest == nil, "Password digest not nill"
    assert user.activation_digest == nil, "Activation digest not nill"
    assert user.activated == nil, "Activated not nill"
    assert user.activated_at == nil, "Activated at not nill"
    assert user.remember_digest == nil, "Remember digest not nill"
    assert user.reset_digest == nil, "Reset digest not nill"
    assert user.reset_sent_at == nil, "Reset sent at not nill"
    assert user.permission_level == nil, "Permission level not nill"
    assert user.permission_level_granted_on == nil, "Permission level granted on not nill"
    assert user.permission_level_granted_by_id == nil, "Permission level granted by ID not nill"
    assert user.deleted, "Deleted flag not set"
  end

  ## test that a non-logged in user can't delete anyone
  test "cant delete unless logged in" do
    user = users(:foo)
    post :destroy, params: { id: user.id }
    user.reload
    assert_not user.deleted, "Unlogged in user deleted"
  end
  
  ## test that a user cannot delete another user
  ## FIX LATER -- ADMINS CAN DELETE OTHER USERS
  test "can only delete yourself" do
    user = users(:foo)
    user2 = users(:bar)
    log_in_as user
    post :destroy, params: { id: user2.id }
	user2.reload
    assert_not user2.deleted, "User deleted by other user"
  end
  
  ## test that a deleted user cannot login
  test "cannot log in after deleted" do
    user = users(:foo)
	log_in_as user
	post :destroy, params: { id: user.id }
    user.reload
	log_in_as user
    assert user.deleted, "User logged in after being deleted"
  end
  
  test "can't update user settings unless logged in as user" do
    log_in_as users(:foo)
    bar = users(:bar)
    post :update, params: { id: users(:bar).id, user: { 
        username: "x",
        email: "x@mail.org",
        role: "student",
        first_name: "X",
        last_name: "Y",
        field_of_study: "XYZ",
        password: "12345678",
        permission_level: "admin"
      } }
    bar.reload
    assert bar.username != "x"
    assert bar.email != "x@mail.org"
  end
  
  test "should update user settings and create permission request" do
    user = users(:bar)
    log_in_as user
    assert_difference "PermissionRequest.count", 1, "Permission request not created" do
      post :update, params: { id: user.id, user: { 
          username: "x",
          email: "x@mail.org",
          role: "student",
          first_name: "X",
          last_name: "Y",
          field_of_study: "XYZ",
          current_password: "password",
          permission_level: "admin",
          password: "12345678",
          password_confirmation: "12345678"
        } }
      user.reload
      assert user.username == "x", "Username not updated: #{user.username}"
      assert user.email == "x@mail.org", "Email not updated: #{user.email}"
      
      assert user.permission_level == "editor", 
        "Permission level saved incorrectly."
      permission_request = PermissionRequest.find_by(user: user)
      assert_not permission_request.nil?
      assert permission_request.level_requested = "admin"
    end
  end
  
  test "should update user settings but not create permission request" do
    user = users(:foo)
    log_in_as user
    assert_difference "PermissionRequest.count", 0, "Permission request created" do
      post :update, params: { id: user.id, user: { 
          username: "x",
          email: "x@mail.org",
          role: "student",
          first_name: "X",
          last_name: "Y",
          field_of_study: "XYZ",
          current_password: "password",
          permission_level: "viewer",
          password: "12345678",
          password_confirmation: "12345678"
        } }
      user.reload
      assert user.username == "x", "Username not updated: #{user.username}"
      assert user.email == "x@mail.org", "Email not updated: #{user.email}"
      
      assert user.permission_level == "viewer", 
        "Permission level saved incorrectly."
    end
  end
  
  test "shouldn't update user settings without correct password" do
    user = users(:foo)
    log_in_as user
    post :update, params: { id: user.id, user: { 
        username: "x",
        email: "x@mail.org",
        role: "student",
        first_name: "X",
        last_name: "Y",
        field_of_study: "XYZ",
        current_password: "123",
        permission_level: "admin"
      } }
    user.reload
    assert user.username != "x", "Username updated"
    assert user.email != "x@mail.org", "Email updated"
  end
  
  ##############################################################################
  ## Testing update_stub
  test "should update an existing user_stub" do
    stub = users(:stub1)
    log_in_as users(:foo)
    new_email = "x@mail.org"
    new_first_name = "X"
    new_last_name = "Y"

    post :update_stub, format: :json, params: { id: stub.id, user: { 
      email: new_email,
      first_name: new_first_name,
      last_name: new_last_name
    } }
    result = JSON.parse(@response.body)
    assert result['success'], @response.body
    assert result['data'].has_key?('user_stub'),
      "Missing user_stub key: #{@response.body}"

    stub.reload
    assert stub.email == new_email, "Email not changed."
    assert stub.first_name == new_first_name, "First name not changed."
    assert stub.last_name == new_last_name, "Last name not changed."

    user_stub = result['data']['user_stub']

    assert user_stub.has_key?('json'), 
      "Missing data.user_stub.json: #{@response.body}"
    assert user_stub['json']['id'] == stub.id, 
      "Wrong user id (expected #{User.last.id}): #{@response.body}"
    assert user_stub['json']['first_name'] == stub.first_name,
      "Wrong first_name (expected #{User.last.first_name}): #{@response.body}"
    assert user_stub['json']['last_name'] == stub.last_name,
      "Wrong last_name (expected #{User.last.last_name}): #{@response.body}"
    assert user_stub['json']['email'] ==stub.email,
      "Wrong email (expected #{User.last.email}): #{@response.body}"
    assert user_stub.has_key?('html'),
      "Missing data.user_stub.html: #{@response.body}"
    # assert false, user_stub['html']
    num_spans = user_stub['html'].scan(/<span\b/).size
    assert num_spans == 2,
      "Missing expected number of span tags (got #{num_spans}, expected 2) "+
      "in data.html: #{user_stub['html']}"
  end

  test "should update an existing user_stub if admin, but not creator" do
    stub = users(:stub1)
    log_in_as users(:user3)
    new_email = "x@mail.org"
    new_first_name = "X"
    new_last_name = "Y"

    post :update_stub, format: :json, params: { id: stub.id, user: { 
      email: new_email,
      first_name: new_first_name,
      last_name: new_last_name
    } }
    result = JSON.parse(@response.body)
    assert result['success'], @response.body
    assert result['data'].has_key?('user_stub'),
      "Missing user_stub key: #{@response.body}"

    stub.reload
    assert stub.email == new_email, "Email not changed."
    assert stub.first_name == new_first_name, "First name not changed."
    assert stub.last_name == new_last_name, "Last name not changed."

    user_stub = result['data']['user_stub']

    assert user_stub.has_key?('json'), 
      "Missing data.user_stub.json: #{@response.body}"
    assert user_stub['json']['id'] == stub.id, 
      "Wrong user id (expected #{User.last.id}): #{@response.body}"
    assert user_stub['json']['first_name'] == stub.first_name,
      "Wrong first_name (expected #{User.last.first_name}): #{@response.body}"
    assert user_stub['json']['last_name'] == stub.last_name,
      "Wrong last_name (expected #{User.last.last_name}): #{@response.body}"
    assert user_stub['json']['email'] ==stub.email,
      "Wrong email (expected #{User.last.email}): #{@response.body}"
    assert user_stub.has_key?('html'),
      "Missing data.user_stub.html: #{@response.body}"
    # assert false, user_stub['html']
    num_spans = user_stub['html'].scan(/<span\b/).size
    assert num_spans == 2,
      "Missing expected number of span tags (got #{num_spans}, expected 2) "+
      "in data.html: #{user_stub['html']}"
  end

  test "shouldn't update an existing user_stub if not the creator or admin" do
    stub = users(:stub1)

    log_in_as users(:bar)
    new_email = "x@mail.org"
    new_first_name = "X"
    new_last_name = "Y"

    post :update_stub, format: :json, params: { id: stub.id, user: { 
      email: new_email,
      first_name: new_first_name,
      last_name: new_last_name
    } }
    result = JSON.parse(@response.body)
    assert_not result['success'], @response.body
    assert result['error'] == "You do not have permissions to modify the requested user stub.",
      "Error message incorrect: #{result['error']}"

    stub.reload
    assert_not stub.email == new_email, "Email changed."
    assert_not stub.first_name == new_first_name, "First name changed."
    assert_not stub.last_name == new_last_name, "Last name changed."
  end

  test "shouldn't update an existing user_stub if not logged in" do
    stub = users(:stub1)

    new_email = "x@mail.org"
    new_first_name = "X"
    new_last_name = "Y"

    post :update_stub, format: :json, params: { id: stub.id, user: { 
      email: new_email,
      first_name: new_first_name,
      last_name: new_last_name
    } }
    result = JSON.parse(@response.body)
    assert_not result['success'], @response.body
    assert result['error'] == "This action requires that you be logged in.",
      "Error message incorrect: #{result['error']}"

    stub.reload
    assert_not stub.email == new_email, "Email changed."
    assert_not stub.first_name == new_first_name, "First name changed."
    assert_not stub.last_name == new_last_name, "Last name changed."
  end


  test "shouldn't update a registered user via update_stub" do
    user = users(:bar)
    log_in_as users(:foo)
    new_email = "x@mail.org"
    new_first_name = "X"
    new_last_name = "Y"

    post :update_stub, format: :json, params: { id: user.id, user: { 
      email: new_email,
      first_name: new_first_name,
      last_name: new_last_name
    } }
    result = JSON.parse(@response.body)
    assert_not result['success'], @response.body
    assert result['error'] == "The requested user is registered an cannot be modified.",
      "Error message incorrect: #{result['error']}"

    user.reload
    assert_not user.email == new_email, "Email changed."
    assert_not user.first_name == new_first_name, "First name changed."
    assert_not user.last_name == new_last_name, "Last name changed."
  end

end