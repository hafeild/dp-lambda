class DatasetsController < ApplicationController
  # before_action :get_response_format
  before_action :logged_in_user, except: [:show, :index]
  before_action :user_can_edit, except: [:show, :index]
  before_action :get_params, only: [:create, :update]
  before_action :get_dataset, except: [:index, :new, :create] 
  before_action :get_verticals, only: [:connect, :disconnect]
  before_action :get_redirect_path, only: [:connect, :disconnect]

  def index
    @datasets = Dataset.all.sort_by { |e| e.name }
  end

  def show
  end

  def new
    @dataset = Dataset.new
  end

  def edit
  end

  ## Creates a new dataset entry. 
  def create

    ## Make sure we have the required fields.
    if get_with_default(@data, :name, "").empty? or 
        get_with_default(@data, :summary, "").empty? or
        get_with_default(@data, :description, "").empty?
      respond_with_error "You must provide a name, summary, and description.",
        new_dataset_path
      return
    end

    ## Create the new entry.
    begin
      ActiveRecord::Base.transaction do
        dataset = Dataset.new(
          creator: current_user, name: @data[:name], summary: @data[:summary], 
          description: @data[:description]
        )

        dataset.save!

        respond_with_success dataset_path(dataset)
      end
    rescue => e
      respond_with_error "There was an error saving the dataset entry.",
        new_dataset_path
    end
  end

  ## Updates a dataset entry. Takes all the usual parameters. The tags,
  ## web_resources, and examples may include "remove" fields along with an
  ## id, which will cause the resource to be disassociated with this project
  ## and deleted altogether if the resource isn't associated with another
  ## vertical entry.
  def update
    begin
      ActiveRecord::Base.transaction do
        @dataset.update(@data.permit(:name, :description, :summary))
        @dataset.save!

        respond_with_success dataset_path(@dataset)
      end
    rescue => e
      respond_with_error "There was an error updating the dataset entry.",
        new_dataset_path
    end  
  end

  ## Deletes the dataset page and any resources connected only to it.
  def destroy
    begin
      ActiveRecord::Base.transaction do

        ## Remove connected resources.
        destroy_isolated_resources(@dataset)

        @dataset.destroy!

        flash[:success] = "Page removed."
        redirect_to datasets_path
      end
    rescue => e
      respond_with_error "There was an error removing the dataset entry.",
        new_dataset_path
    end
  end

  def connect
    begin
      @vertical.datasets << @dataset
      @vertical.save!
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The dataset could not be associated with the "+
        "requested vertical.", @redirect_path
    end
  end

  def disconnect
    begin
      if @vertical.datasets.exists?(id: @dataset.id)
        @vertical.datasets.delete(@dataset)
        @vertical.save! 
      end
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The dataset could not be disassociated with the"+
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
        @data = params.require(:dataset).permit(:name, :summary, :description,
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


    ## Gets the dataset specified by the id in the parameters. If it doesn't
    ## exist, a 404 page is displayed.
    def get_dataset
      @dataset = Dataset.find_by(id: params.require(:id))
      if @dataset.nil?
        error = "No dataset with the specified id exists."
        respond_to do |format|
          format.json {render json: {success: false, error: error}}
          format.html do
            render file: "#{Rails.root}/public/404.html" , status: 404
          end
        end
      end
    end
end
