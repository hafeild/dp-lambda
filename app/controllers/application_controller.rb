class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  include PermissionsHelper
  include ApplicationHelper

  private

    ## Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    ## Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    ## Checks if every key in a list of keys is present in the given hash.
    ## @param hash The hash map to consider.
    ## @param keys The list of keys to check.
    def has_keys?(hash, keys)
      keys.each do |key|
        unless hash.key?(key)
          return false
        end
      end
      true
    end

    ## Gets the value in the hash associated with the given key if it exists,
    ## otherwise returns the default.
    ## @param hash The hash.
    ## @param key The key.
    ## @param default The default to return if key is not in hash.
    def get_with_default(hash, key, default)
      hash.key?(key) ? hash[key] : default
    end

end
