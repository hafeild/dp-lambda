class SoftwareController < ApplicationController
  # before_action :get_response_format
  before_action :logged_in_user, except: [:show, :index]
  before_action :user_can_edit, except: [:show, :index]
  before_action :get_params, only: [:create, :update]
  before_action :get_software,  except: [:connect_index, :index, :new, :create] 
  before_action :get_verticals
  before_action :get_redirect_path

  def index
    @software = Software.all.sort_by { |e| e.name }
  end

  def connect_index
    @software = Software.all.sort_by { |e| e.name }
    if @vertical.class == Software
      @software.delete(@vertical)
    end
  end

  def show
  end

  def new
    @software = Software.new
  end

  def edit
  end

  ## Creates a new software entry. 
  def create

    ## Make sure we have the required fields.
    # if get_with_default(@data, :name, "").empty? or 
    #     get_with_default(@data, :summary, "").empty? or
    #     get_with_default(@data, :description, "").empty?
    #   respond_with_error "You must provide a name, summary, and description.",
    #     new_software_path
    #   return
    # end

    ## Create the new entry.
    @data[:creator] = current_user
    @software = Software.new(@data)
    begin
      ActiveRecord::Base.transaction do
        @software.save!
        respond_with_success get_redirect_path(software_path(@software))
      end
    rescue => e
      respond_with_error "There was an error saving the software entry: #{e}.",
        'new', true, false
    end
  end

  ## Updates a software entry. Takes all the usual parameters. The tags,
  ## web_resources, and examples may include "remove" fields along with an
  ## id, which will cause the resource to be disassociated with this project
  ## and deleted altogether if the resource isn't associated with another
  ## vertical entry.
  def update
    begin
      @software.update(@data.permit(:name, :description, :summary))
      ActiveRecord::Base.transaction do
        @software.save!
        @software.reindex_associations
        
        respond_with_success get_redirect_path(software_path(@software))
      end
    rescue => e
      respond_with_error "There was an error updating the software entry: #{e}.",
        'edit', true, false
    end  
  end

  ## Deletes the software page and any resources connected only to it.
  def destroy
    begin
      ActiveRecord::Base.transaction do

        ## Remove connected resources.
        destroy_isolated_resources(@software)
        @software.delete_from_connection
        @software.destroy!

        flash[:success] = "Page removed."
        redirect_to software_index_path
      end
    rescue => e
      respond_with_error "There was an error removing the software entry.",
        software_path(@software)
    end
  end

  def connect
    begin
      @vertical.software << @software
      @vertical.save!
      @software.reload
      @software.save!

      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The software could not be associated with the "+
        "requested vertical.", @redirect_path
    end
  end

  def disconnect
    begin
      if @vertical.software.exists?(id: @software.id)
        @vertical.software.delete(@software)
        @vertical.save! 
        @software.reload
        @software.save!
      end
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The software could not be disassociated with the"+
        " requested vertical.", @redirect_path
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
        @data = params.require(:software).permit(:name, :summary, :description,
          :thumbnail, 
          :bootsy_image_gallery_id,
          tags: [:id, :text, :remove], 
          web_resources: [:id, :url, :description, :remove], 
          examples: [:id, :title, :description, :software_id, :analysis_id,
            :dataset_id, :remove])
      rescue => e
        respond_with_error "Required parameters not supplied.", root_path
      end
    end


    ## Gets the software specified by the id in the parameters. If it doesn't
    ## exist, a 404 page is displayed.
    def get_software
      @software = Software.find_by(id: params.require(:id))
      if @software.nil?
        error = "No software with the specified id exists."
        respond_to do |format|
          format.json {render json: {success: false, error: error}}
          format.html do
            render file: "#{Rails.root}/public/404.html" , status: 404
          end
        end
      end
    end
end
