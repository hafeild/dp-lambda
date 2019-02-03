class AssignmentGroupsController < ApplicationController
  # before_action :get_response_format
  before_action :logged_in_user, except: [:show, :index]
  before_action :user_can_edit, except: [:show, :index]
  before_action :get_params, only: [:create, :update]
  before_action :get_authors, only: [:create, :update]
  before_action :get_assignment_group,  except: [:connect_index, :index, :new, :create] 
  before_action :get_verticals
  before_action :get_redirect_path

  def index
    @assignment_groups = AssignmentGroup.all.sort_by { |e| e.name }
  end

  def connect_index
    @assignment_groups = AssignmentGroup.all.sort_by { |e| e.name }
    if @vertical.class == AssignmentGroup
      @assignment_groups.delete(@vertical)
    end
  end

  def show
  end

  def new
    @assignment_group = AssignmentGroup.new
  end

  def edit
  end

  ## Creates a new assignment_group entry. 
  def create

    ## Make sure we have the required fields.
    if get_with_default(@data, :name, "").empty? or 
        get_with_default(@data, :summary, "").empty? or
        @authors.empty?

      # respond_with_error "You must provide a name, summary, and at least one author.",
      #   new_assignment_group_path
      @data[:authors] = @authors
      @assignment_group = AssignmentGroup.new(@data)

      respond_with_error "You must provide a name, summary, and at least one author.",
        'new', true, false
      return
    end

    ## Create the new entry.
    begin
      ActiveRecord::Base.transaction do
        @data[:creator] = current_user
        @data[:authors] = @authors
  
        assignment_group = AssignmentGroup.create!(@data)
        flash[:success] = "Assignment created successfully!"
        respond_with_success get_redirect_path(assignment_group_path(assignment_group))
      end
    rescue => e
      # puts "#{@author_ids} #{e.message} #{e.backtrace.join("\n")}"
      respond_with_error "There was an error saving the assignment group entry: #{e}",
        'new', true, false
    end
  end

  ## Updates a assignment_group entry. Takes all the usual parameters. The tags
  ## and web_resources may include "remove" fields along with an
  ## id, which will cause the resource to be disassociated with this project
  ## and deleted altogether if the resource isn't associated with another
  ## vertical entry.
  def update
    begin
      ActiveRecord::Base.transaction do
        @data[:authors] = @authors if params.require(:assignment_group).has_key?(:authors)
        @assignment_group.update!(@data)
        @assignment_group.reindex_associations
        flash[:success] = "Assignment updated successfully!"
        respond_with_success get_redirect_path(assignment_group_path(@assignment_group))
      end
    rescue => e
      # puts e.message
      @assignment_group.update_attributes(@data)
      respond_with_error "There was an error updating the assignment group entry.",
      'edit', true, false
    end  
  end

  ## Deletes the assignment_group page and any resources connected only to it.
  def destroy
    begin
      ActiveRecord::Base.transaction do

        ## Remove connected resources.
        destroy_isolated_resources(@assignment_group)
        @assignment_group.destroy!

        flash[:success] = "Page removed."
        redirect_to assignment_groups_path
      end
    rescue => e
      # puts "#{e.message}"
      respond_with_error "There was an error removing the assignment group entry. #{e}",
        assignment_group_path(@assignment_group)
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
        @data = params.require(:assignment_group).permit(
          :name, :summary, :description, :thumbnail_url
        )
        @author_ids = get_with_default(
          params.require(:assignment_group).permit(:authors), :authors, "")
      rescue => e
        respond_with_error "Required parameters not supplied.", root_path
      end
    end


    ## Gets the assignment specified by the id in the parameters. If it doesn't
    ## exist, a 404 page is displayed.
    def get_assignment_group
      @assignment_group = AssignmentGroup.find_by(id: params.require(:id))
      if @assignment_group.nil?
        error = "No assignment group with the specified id exists."
        respond_to do |format|
          format.json {render json: {success: false, error: error}}
          format.html do
            render file: "#{Rails.root}/public/404.html" , status: 404
          end
        end
      end
    end

    ## Extracts the authors corresponding to the provided author ids.
    def get_authors
      begin
        if @author_ids.empty?
          @authors = []
        else
          @authors = @author_ids.split(",").map{|author_id| User.find_by(id: author_id)}
        end
      rescue => e 
        # puts "#{@author_ids} #{e.message}"
        respond_with_error "One or more authors do not exist.", root_path
      end
    end
end
