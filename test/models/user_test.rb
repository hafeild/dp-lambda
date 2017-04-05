require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = users(:foo)
  end

  test "should be valid" do 
    assert @user.valid?
  end

  test "first and last name should be present" do
    @user.first_name = "       "
    assert_not @user.valid?
    @user.first_name = "a"
    @user.last_name = "       "
    assert_not @user.valid?
  end

  test "password should not be shorter than 8 characters" do
    @user.password = @user.password_confirmation = "1234567"
    assert_not @user.valid?
  end

  test "password should not be longer than 50 characters" do
    @user.password = @user.password_confirmation = "1"*51
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "first and last name should not be too long" do
    @user.first_name = "a" * 51
    assert_not @user.valid?

    @user.first_name = "a"
    @user.last_name = "a" * 51
    assert_not @user.valid?
  end

  test "username should not be too long" do
    @user.username = "a" * 51
    assert_not @user.valid?
  end

  test "username should be present" do
    @user.username = ""
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end


  test "username addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.username = @user.username.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  # test "authenticated? should return false for a user with nil digest" do
  #   assert_not @user.authenticated?(:remember, '')
  # end
end
