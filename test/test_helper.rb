ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include ApplicationHelper

  # Returns true if a test user is logged in.
  def is_logged_in?
    not session[:user_id].nil?
  end

  # Logs in a test user.
  # def log_in_as(user, options = {})
  #   password    = options[:password]    || 'password'
  #   remember_me = options[:remember_me] || '1'
  #   if integration_test?
  #     post login_path, params: { session: { username:    user.username,
  #                                password:    password,
  #                                remember_me: remember_me } }
  #   else
  #     session[:user_id] = user.id
  #   end
  # end


  # Logs in a test user.
  def log_in_as(user)
    session[:user_id] = user.id
  end 

  def log_in_as_integration(user, options={})
    password    = options.has_key?(:password) ? options[:password] : 'password'
    remember_me = options.has_key?(:remember_me) ? options[:remember_me] : '1'
    post login_path, params: { session: { 
        username:       user.email,
        password:    password,
        remember_me: remember_me } }
  end


  private

    # Returns true inside an integration test.
    def integration_test?
      defined?(post_via_redirect)
    end
end
