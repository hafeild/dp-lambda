class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  include PermissionsHelper
  include ApplicationHelper

  private

    ## Confirms a logged-in user.
    # def logged_in_user
    #   unless logged_in?
    #     store_location
    #     flash[:danger] = "Please log in."
    #     redirect_to login_url
    #   end
    # end

    ## Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        respond_with_error "This action requires that you be logged in.", 
          login_path
      end
    end

    ## Checks if the logged in user can make edits. If not, redirect and 
    ## displays an error message.
    def user_can_edit
      unless logged_in? and can_edit?
        respond_with_error(
          "You must have editor permissions to edit this content.", 
          root_path)
      end
    end

    ## Checks if the logged in user is an admin. If not, redirect and 
    ## displays an error message.
    def user_is_admin
      unless logged_in? and is_admin?
        respond_with_error(
          "You must have admin permissions to perform this action.", 
          root_path)
      end
    end

    ## Check if the given permission level is valid.
    def valid_permission_level?(level)
      level == "viewer" or level == "editor" or level == "admin"
    end

    ## Returns a sanitized permission level.
    def get_sanitized_permission_level(level)
      level.downcase!
      if valid_permission_level? level
        return level
      end
      return "viewer"
    end


    ## Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    ## Sends a notification about a permission request to all admin users.
    def send_admin_notification_email(permission_requested)
      User.admins.each do |admin|
        AdminMailer.permission_request_notification(
          admin, permission_requested).deliver_now
      end
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

    ## Responds with an error, either as JSON or HTML based on the requested
    ## format.
    ## @param error The error to return.
    ## @param redirect_path The path to return to if 'back' isn't an option. 
    ##                      Defaults to root_path.
    ## @param render_it If true, renders the page `redirect_path`. Default: false.
    def respond_with_error(error, redirect_path=root_path, render_it=false, set_flash=true)
      respond_to do |format|
        format.json { render json: {success: false, error: error} }
        format.html do 
          flash[:danger] = error if set_flash
          if render_it
            render redirect_path 
          else
            redirect_back_or redirect_path
          end
        end
      end
    end

    ## Responds successfully, either as JSON or HTML based on the requested
    ## format.
    ## @param path The path to redirect to.
    def respond_with_success(path, data={})
      respond_to do |format|
        format.json { render json: {success: true, redirect: path, data: data} }
        format.html { redirect_to path }
      end
    end


    ## Gets the associated software or other vertical.
    def get_verticals
      begin
        @vertical_form_id = nil

        if params.key? :software_id
          @vertical = Software.find(params[:software_id]) 
          @vertical_form_id = :software_id
        elsif params.key? :dataset_id
          @vertical = Dataset.find(params[:dataset_id])
          @vertical_form_id = :dataset_id
        elsif params.key? :analysis_id
          @vertical = Analysis.find(params[:analysis_id]) 
          @vertical_form_id = :analysis_id
        elsif params.key? :assignment_id
          @vertical = Assignment.find(params[:assignment_id]) 
          @vertical_form_id = :assignment_id
        elsif params.key? :assignment_group_id
          @vertical = AssignmentGroup.find(params[:assignment_group_id]) 
          @vertical_form_id = :assignment_group_id
        elsif params.key? :example_id
          @vertical = Example.find(params[:example_id]) 
          @vertical_form_id = :example_id
        end

      rescue
        error = "Invalid vertical id given."

      end
    end

    ## Gets the back path (where to go on submit or cancel).
    def get_redirect_path(default=root_path)
      if params.key? :redirect_path
        @redirect_path = params[:redirect_path]
      elsif not @vertical.nil?
        if @vertical.class == "Assignment"
          @redirect_path = show_assignment_path(@vertical)
        else
          @redirect_path = get_vertical_path(@vertical)
        end
      else
        @redirect_path = default
      end
      @redirect_path
    end

end
