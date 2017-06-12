class AssignmentResultsController < ApplicationController
  before_action :logged_in_user, except: [:show]
  before_action :user_can_edit, except: [:show]
  before_action :get_simple_params, only: [:new, :edit]
  before_action :get_assignment_result
  before_action :get_assignment
  before_action :get_redirect_path
  before_action :get_params, except: [:show, :edit, :new, :destroy]

  def show
  end

  def new
  end

  def edit
  end

  def create
    begin
      @params[:creator] = current_user
      @params[:assignment] = @assignment
      @assignment_result = AssignmentResult.create! @params
      respond_with_success @redirect_path
    rescue => e
      respond_with_error("The assignment result could not be created; check "+
        "the parameters.", new_assignment_assignment_result_path(@assignment))
    end
  end

  def update
    begin
      @assignment_result.update_attributes! @params
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The assignment result could not be updated.", 
        edit_assignment_result_path(@assignment_result)
    end
  end

  def destroy
    begin
      @assignment_result.destroy!
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The assignment result could not be updated.", 
        @redirect_path
    end
  end

  private

    def get_simple_params
      @params = params.permit(:assignment_id, :redirect_path, :id)
    end


    ## Extracts the allowed parameters into a global named @data.
    def get_params
      begin
        @params = params.require(:assignment_result).permit(
          :instructor, :course_prefix, :course_number, :course_title,
          :semester, :field_of_study, :project_length_weeks,
          :students_given_assignment, :instruction_hours, 
          :average_student_score, :outcome_summary)
      rescue => e
        respond_with_error "Required parameters not supplied.",
          new_assignment_assignment_result_path(@assignment)
      end
    end

    def get_assignment_result
      if params.key? :id
        @assignment_result = AssignmentResult.find(params[:id])
      else
        @assignment_result = AssignmentResult.new
      end
    end

    def get_assignment
      if params.key? :assignment_id
        @assignment = Assignment.find_by(id: params[:assignment_id])
        if @assignment.nil?
          respond_with_error "A valid assignment id must be provided."
        end
      elsif not @assignment_result.assignment.nil?
        @assignment = @assignment_result.assignment
      else
        respond_with_error "A assignment id must be provided."
      end
    end

    def get_redirect_path
      @redirect_path = assignment_path(@assignment)
    end
end