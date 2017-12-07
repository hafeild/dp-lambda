require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "account_activation" do
    user = users(:foo)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "Alice account activation", mail.subject
    assert_equal [user.email],               mail.to
    assert_equal [ENV['FROM_EMAIL']],        mail.from
    assert_match user.first_name,            mail.body.encoded
    assert_match user.activation_token,      mail.body.encoded
    assert_match CGI::escape(user.username), mail.body.encoded
  end

  test "email_verification" do
    user = users(:foo)
    user.activation_token = User.new_token
    mail = UserMailer.email_verification(user)
    assert_equal "Alice email verification", mail.subject
    assert_equal [user.email],               mail.to
    assert_match user.username,              mail.body.encoded
    assert_equal [ENV['FROM_EMAIL']],        mail.from
    assert_match user.first_name,            mail.body.encoded
    assert_match user.activation_token,      mail.body.encoded
    assert_match CGI::escape(user.username), mail.body.encoded
  end

  test "password_reset" do
    user = users(:foo)
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)
    assert_equal "Alice password reset",     mail.subject
    assert_equal [user.email],               mail.to
    assert_equal [ENV['FROM_EMAIL']],        mail.from
    assert_match user.first_name,            mail.body.encoded
    assert_match user.reset_token,           mail.body.encoded
    assert_match CGI::escape(user.username), mail.body.encoded
  end

  test "permissions_changed" do
    user = users(:foo)
    mail = UserMailer.permissions_changed(user)
    assert_equal "Alice permissions changed",     mail.subject
    assert_equal [user.email],               mail.to
    assert_equal [ENV['FROM_EMAIL']],        mail.from
    assert_match user.first_name,            mail.body.encoded
    assert_match user.permission_level,      mail.body.encoded
  end
end
