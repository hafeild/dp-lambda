require 'test_helper'
## Modified from https://www.railstutorial.org/book/account_activation_password_reset
class SoftwareRenderTest < ActionDispatch::IntegrationTest

  ## Show tests.
  test "should display software page that exists without being logged in" do 
    software = software(:one)

    get software_path(software.id)
    assert_template "software/show"
    assert_select ".name", software.name
    assert_select ".summary", software.summary
    assert_select ".description", software.description
  end

  test "should display a 404 page if id isn't valid" do 
    response = get software_path(-1)
    assert response == 404
    assert_select "h1", "The page you were looking for doesn't exist."
  end

end