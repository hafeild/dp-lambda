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
        error = "You must be logged in to modify content."
        respond_to do |format|
          format.json { render json: {success: false, error: error} }
          format.html do
            store_location
            flash[:danger] = error
            redirect_to login_path
          end
        end
      end
    end


    ## Checks if the logged in user can make edits. If not, redirect. and 
    ## displays an error message.
    def user_can_edit
      unless can_edit?
        error = "You do not have permission to edit this content."
        respond_to do |format|
          format.json { render json: {success: false, error: error} }
          format.html do
            flash[:danger] = error 
            redirect_back_or root_path
          end
        end
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

    ## Responds with an error, either as JSON or HTML based on the requested
    ## format.
    ## @param error The error to return.
    ## @param redirect_path The path to return to if 'back' isn't an option. 
    ##                      Defaults to root_path.
    def respond_with_error(error, redirect_path=root_path)
      respond_to do |format|
        format.json { render json: {success: false, error: error} }
        format.html do 
          flash[:danger] = error
          redirect_back_or redirect_path
        end
      end
    end

    ## Responds successfully, either as JSON or HTML based on the requested
    ## format.
    ## @param path The path to redirect to.
    def respond_with_success(path)
      respond_to do |format|
        format.json { render json: {success: true, redirect: path} }
        format.html { redirect_to path }
      end
    end


    ## Gets the associated software or other vertical.
    def get_verticals
      begin
        @vertical_form_id = nil
        @vertical = nil
        @software = nil
        @dataset = nil

        if params.key? :software_id
          @software = Software.find(params[:software_id]) 
          @vertical = @software
          @vertical_form_id = :software_id
        elsif params.key? :dataset_id
          @dataset = Dataset.find(params[:dataset_id]) 
          @vertical = @dataset
          @vertical_form_id = :dataset_id
        end

      rescue
        error = "Invalid vertical id given."

      end
    end


    ## Gets the back path (where to go on submit or cancel).
    def get_redirect_path
      if params.key? :redirect_path
        @redirect_path = params[:redirect_path]
      elsif not @software.nil?
        @redirect_path = software_path(@software.id)
      elsif not @dataset.nil?
        @redirect_path = dataset_path(@dataset)
      else
        @redirect_path = root_path
      end
    end

end
