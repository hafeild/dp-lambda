require 'test_helper'

class AdminMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers
  test "permission_request_notification" do
    admin = users(:foo)
    permission_request = permission_requests(:pr1)
    mail = AdminMailer.permission_request_notification(admin, permission_request)
    assert_equal "Alice: new permission request", mail.subject
    assert_equal [admin.email],               mail.to
    assert_equal [ENV['FROM_EMAIL']],         mail.from
    assert_match admin.first_name,            mail.body.encoded
    url = permission_request_url(permission_request, :host => ENV['DOMAIN'])
    assert_match url, mail.body.encoded
  end
  
end
