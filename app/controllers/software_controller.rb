class SoftwareController < ApplicationController
  # before_action :get_response_format
  before_action :logged_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_action :user_can_edit, only: [:new, :create, :edit, :update, :destroy]
  before_action :get_params, only: [:create, :update]
  before_action :get_software, only: [:update, :destroy, :show, :edit]

  def index
    @software = Software.all.sort_by { |e| e.name }
  end

  def show
  end

  def new
    @software = Software.new
  end

  def edit
  end

  ## Creates a new software entry. It assumes the following parameter structure:
  ##
  ##  id: ...
  ##  software: {
  ##    name: ...
  ##    summary: ...
  ##    description: ...
  ##    tags*: [text, ...]
  ##    web_resources*: {
  ##      id*: ...
  ##      url**: ...
  ##      description**: ...
  ##    }
  ##    examples*: {
  ##      id*: ...
  ##      title**: ...
  ##      description**: ...
  ##      software_id*: ...
  ##      analyses_id*: ...
  ##      dataset_id*: ...
  ##    }
  ## }
  ##    
  ## * is optional; in the case that ids are supplied, any existing element
  ##   will have its information updated with the other values passed in. 
  ## ** optional in the presence of an optional id, required otherwise.
  def create

    ## Make sure we have the required fields.
    if not @data.key?(:name) or @data[:name].empty? or 
        not @data.key?(:summary) or @data[:summary].empty? or 
        not @data.key?(:description) or @data[:description].empty?
      error = "You must provide a name, summary, and description."
      respond_to do |format|
        format.json { render json: {success: false, error: error} }
        format.html do
          flash[:danger] = error
          redirect_back_or new_software_path
        end
      end
      return
    end

    ## Create the new entry.
    begin
      ActiveRecord::Base.transaction do
        software = Software.new(
          creator: current_user, name: @data[:name], summary: @data[:summary], 
          description: @data[:description]
        )

        ## Process tags.
        update_tags(software)

        ## Process web resources.
        update_web_resources(software)

        ## Process examples.
        update_examples(software)

        software.save!
        # render plain: "#{@data.to_h.to_json} -- #{params.require(:software).to_unsafe_h.to_json}"

        respond_to do |format|
          format.json { render json: 
            {success: true, redirect: software_path(software.id)} }
          format.html { redirect_to software_path(software.id) }
        end
      end
    rescue => e
      error = "There was an error saving the software entry."
      respond_to do |format|
        format.json { render json: {success: false, error: error} }
        format.html do 
          flash[:danger] = error
          redirect_back_or new_software_path
          #render plain: e
        end
      end
    end
  end

  ## Updates a software entry. Takes all the usual parameters. The tags,
  ## web_resources, and examples may include "remove" fields along with an
  ## id, which will cause the resource to be disassociated with this project
  ## and deleted altogether if the resource isn't associated with another
  ## vertical entry.
  def update
    begin
      ActiveRecord::Base.transaction do
        @software.update(@data.permit(:name, :description, :summary))

        ## Process tags.
        update_tags(@software, true)

        ## Process web resources.
        update_web_resources(@software, true)

        ## Process examples.
        update_examples(@software, true)

        @software.save!

        respond_to do |format|
          format.json {render json: {success: true, 
              redirect: software_path(@software.id)}}
          format.html {redirect_to software_path(@software.id)}
        end
      end
    rescue => e
      error = e #"There was an error updating the software entry."
      respond_to do |format|
        format.json {render json: {success: false, error: error}}
        format.html do 
          flash[:danger] = error 
          redirect_back_or new_software_path
          # render plain: e
        end
      end
    end  
  end

  ## Deletes the software page and any resources connected only to it.
  def destroy
    begin
      ActiveRecord::Base.transaction do

        ## Remove connected resources.
        destroy_isolated_resources(@software)

        @software.destroy!

        flash[:success] = "Page removed."
        redirect_to software_index_path
      end
    rescue => e
      error = "There was an error removing the software entry."
      flash[:danger] = error 
      redirect_back_or new_software_path
      # render plain: e
    end
  end

  private

    ## Detects the requested response format -- HTML or JSON.
    def get_response_format
      @json = (params.key? :format and params[:format] == "json")
    end

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

    ## Extracts the allowed parameters into a global named @data.
    def get_params
      begin
        @data = params.require(:software).permit(:name, :summary, :description,
          :thumbnail, 
          tags: [:id, :text, :remove], 
          web_resources: [:id, :url, :description, :remove], 
          examples: [:id, :title, :description, :software_id, :analysis_id,
            :dataset_id, :remove])
      rescue => e
        error = "Required parameters not supplied."
        respond_to do |format|
          format.json { render json: {success: false, error: error} }
          format.html do 
            flash[:danger] = error
            redirect_back_or root_path
          end
        end
      end
    end


    ## Gets the software specified by the id in the parameters. If it doesn't
    ## exist, a 404 page is displayed.
    def get_software
      @software = Software.find_by(id: params.require(:id))
      if @software.nil?
        render file: "#{Rails.root}/public/404.html" , status: 404
      end
    end
end
