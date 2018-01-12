class AttachmentsController < ApplicationController
  before_action :logged_in_user, except: [:index]
  before_action :user_can_edit, except: [:index]
  before_action :get_redirect_path
  before_action :get_verticals_or_example
  
  def index
  end

  def create
    
  end
  
  def destroy
    
  end
  
  private
  
    ## Checks for a parameter of the form <vertical>_id (e.g., software_id)
    ## or example_id. Renders an error if not found.
    def get_verticals_or_example
      get_verticals
      if @vertical_form_id.nil? and params.key? :example_id
        @vertical = Example.find(params[:example_id])
        @vertical_form_id = :example_id
      else
        respond_with_error "Attachments must be associated with a vertical or example.", 
          @redirect_path
      end
    end
  
end