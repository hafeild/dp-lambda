class AssignmentsController < ApplicationController
  # before_action :get_response_format
  before_action :logged_in_user, except: [:show, :index]
  before_action :user_can_edit, except: [:show, :index]
  before_action :get_params, only: [:create, :update]
  before_action :get_assignment,  except: [:connect_index, :index, :new, :create] 
  before_action :get_verticals
  before_action :get_redirect_path

  def index
    @assignments = Assignment.all.sort_by { |e| e.name }
  end

  def connect_index
    @assignments = Assignment.all.sort_by { |e| e.name }
    if @vertical.class == Assignment
      @assignments.delete(@vertical)
    end
  end

  def show
  end

  def new
    @assignment = Assignment.new
  end

  def edit
  end

  ## Creates a new assignment entry. 
  def create

    ## Make sure we have the required fields.
    if get_with_default(@data, :name, "").empty? or 
        get_with_default(@data, :summary, "").empty? or
        #get_with_default(@data, :description, "").empty? or
        get_with_default(@data, :author, "").empty?
      respond_with_error "You must provide an author, name, and summary.",
        new_assignment_path
      return
    end

    ## Create the new entry.
    begin
      ActiveRecord::Base.transaction do
        @data[:creator] = current_user
        assignment = Assignment.create!(@data)
        respond_with_success get_redirect_path(assignment_path(assignment))
      end
    rescue => e
      respond_with_error "There was an error saving the assignment entry.",
        new_assignment_path
    end
  end

  ## Updates a assignment entry. Takes all the usual parameters. The tags,
  ## web_resources, and examples may include "remove" fields along with an
  ## id, which will cause the resource to be disassociated with this project
  ## and deleted altogether if the resource isn't associated with another
  ## vertical entry.
  def update
    begin
      ActiveRecord::Base.transaction do
        @assignment.update!(@data)
        respond_with_success get_redirect_path(assignment_path(@assignment))
      end
    rescue => e
      respond_with_error "There was an error updating the assignment entry.",
        new_assignment_path
    end  
  end

  ## Deletes the assignment page and any resources connected only to it.
  def destroy
    begin
      ActiveRecord::Base.transaction do

        ## Remove connected resources.
        destroy_isolated_resources(@assignment)
        @assignment.destroy!

        flash[:success] = "Page removed."
        redirect_to assignments_path
      end
    rescue => e
      respond_with_error "There was an error removing the assignment entry. #{e}",
        new_assignment_path
    end
  end

  def connect
    begin
      if @vertical.class == Assignment
        @vertical.assignments_related_to << @assignment
      else
        @vertical.assignments << @assignment
      end
      @vertical.save!
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "These assignments could not be linked.", 
        @redirect_path
    end
  end

  def disconnect
    begin
      if @vertical.class == Assignment
        if @vertical.assignments_related_to.exists?(id: @assignment.id)
          @vertical.assignments_related_to.delete(@assignment)
        end
      else
        if @vertical.assignments.exists?(id: @assignment.id)
          @vertical.assignments.delete(@assignment)
        end
      end
      @vertical.save! 
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "These assignments could not be unlinked.", 
        @redirect_path
    end
  end

  private

    ## Detects the requested response format -- HTML or JSON.
    def get_response_format
      @json = (params.key? :format and params[:format] == "json")
    end

    ## Extracts the allowed parameters into a global named @data.
    def get_params
      begin
        @data = params.require(:assignment).permit(
          :author, :name, :summary, :description, :thumbnail_url,
          :learning_curve, :instruction_hours
        )
      rescue => e
        respond_with_error "Required parameters not supplied.", root_path
      end
    end


    ## Gets the assignment specified by the id in the parameters. If it doesn't
    ## exist, a 404 page is displayed.
    def get_assignment
      @assignment = Assignment.find_by(id: params.require(:id))
      if @assignment.nil?
        error = "No assignment with the specified id exists."
        respond_to do |format|
          format.json {render json: {success: false, error: error}}
          format.html do
            render file: "#{Rails.root}/public/404.html" , status: 404
          end
        end
      end
    end
end
