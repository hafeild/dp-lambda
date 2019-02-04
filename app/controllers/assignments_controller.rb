class AssignmentsController < ApplicationController
  # before_action :get_response_format
  before_action :logged_in_user, except: [:show, :index]
  before_action :user_can_edit, except: [:show, :index]
  before_action :get_params, only: [:create, :update]
  before_action :get_instructors, only: [:create, :update]
  before_action :get_assignment,  except: [:connect_index, :index, :new, :create]
  before_action :get_assignment_group, only: [:create, :update, :show, :new, :edit] 
  before_action :get_verticals
  before_action :get_redirect_path

  def index
    @assignments = Assignment.all.sort_by { |e| e.assignment_group.name }
  end

  def connect_index
    @assignments = Assignment.all.sort_by { |e| e.assignment_group.name }
    if @vertical.class == Assignment
      @assignments.delete(@vertical)
    end
  end

  def show
    render "assignment_groups/show"
  end

  def new
    @assignment = Assignment.new
  end

  def edit
  end

  ## Creates a new assignment entry. 
  def create

    ## Make sure we have the required fields.
    #   if get_with_default(@data, :course_prefix, "").empty? or 
    #     get_with_default(@data, :course_number, "").empty? or 
    #     get_with_default(@data, :course_title, "").empty? or 
    #     get_with_default(@data, :field_of_study, "").empty? or
    #     get_with_default(@data, :semester, "").empty? or
    #     @instructors.empty?
    #   @data[:instructors] = @instructors
    #   @assignment = Assignment.new(@data)
    #   respond_with_error "You must provide a course prefix, number, and title, a field of study, a semester, and one or more instructors.",
    #     'new', true, false
    #   return
    # end

    @data[:creator] = current_user
    @data[:assignment_group] = @assignment_group
    @data[:instructors] = @instructors
    @assignment = Assignment.new(@data)

    ## Create the new entry.
    begin
      ActiveRecord::Base.transaction do

        @assignment.save!
        @assignment.reload
        flash[:success] = "Assignment version successfully created!"
        respond_with_success assignment_path(@assignment)
      end
    rescue => e
      # puts "#{@instructor_ids} #{e.message} #{e.backtrace.join("\n")}"
      respond_with_error "There was an error saving the assignment entry: #{e}.",
        'new', true, false
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
        @data[:instructors] = @instructors if params.require(:assignment).has_key?(:instructors)
        @assignment.update!(@data)
        @assignment.reindex_associations
        respond_with_success assignment_group_assignment_path(@assignment.assignment_group,@assignment)
      end
    rescue => e
      respond_with_error "There was an error updating the assignment entry.",
        'edit', true, false
    end  
  end

  ## Deletes the assignment page and any resources connected only to it.
  def destroy
    begin
      ActiveRecord::Base.transaction do

        ## Remove connected resources.
        destroy_isolated_resources(@assignment)
        @assignment.delete_from_connection
        @assignment.destroy!

        flash[:success] = "Page removed."
        redirect_to assignment_group_path(@assignment.assignment_group)
      end
    rescue => e
      # puts "#{e.message}"
      respond_with_error "There was an error removing the assignment entry. #{e}",
        assignment_path(@assignment)
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
      @assignment.reload
      @assignment.save!
      
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
      @assignment.reload
      @assignment.save!

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
          :notes, :course, :course_prefix, :course_number, :course_title,
          :semester, :learning_curve, :field_of_study, :project_length_weeks, 
          :students_given_assignment, :instruction_hours, :average_student_score,
          :outcome_summary
        )
        @instructor_ids = get_with_default(
          params.require(:assignment).permit(:instructors), :instructors, "")
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

    def get_assignment_group
      if params.key? :assignment_group_id
        @assignment_group = AssignmentGroup.find_by(id: params[:assignment_group_id])
        if @assignment_group.nil?
          respond_with_error "A valid assignment_group id must be provided."
        end
      elsif not @assignment.assignment_group.nil?
        @assignment_group = @assignment.assignment_group
      else
        respond_with_error "An assignment_group id must be provided."
      end
    end

    ## Extracts the instructors corresponding to the provided author ids.
    def get_instructors
      begin
        if @instructor_ids.empty?
          @instructors = []
        else
          @instructors = @instructor_ids.split(",").map{|instructor_id| 
            User.find_by(id: instructor_id)}
        end
      rescue => e 
        # puts "#{@instructor_ids} #{e.message}"
        respond_with_error "One or more instructors do not exist.", root_path
      end
    end
end
