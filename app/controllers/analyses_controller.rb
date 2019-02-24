class AnalysesController < ApplicationController
  # before_action :get_response_format
  before_action :logged_in_user, except: [:show, :index]
  before_action :user_can_edit, except: [:show, :index]
  before_action :get_params, only: [:create, :update]
  before_action :get_analysis,  except: [:connect_index, :index, :new, :create] 
  before_action :get_verticals
  before_action :get_redirect_path

  def index
    @analyses = Analysis.all.sort_by { |e| e.name }
  end

  def connect_index
    @analyses = Analysis.all.sort_by { |e| e.name }
    if @vertical.class == Analysis
      @analyses.delete(@vertical)
    end
  end

  def show
  end

  def new
    @analysis = Analysis.new
  end

  def edit
  end

  ## Creates a new analysis entry. 
  def create
    @data[:creator] = current_user
    @analysis = Analysis.new(@data)

    # ## Make sure we have the required fields.
    # if get_with_default(@data, :name, "").empty? or 
    #     get_with_default(@data, :summary, "").empty? or
    #     get_with_default(@data, :description, "").empty?
    #   respond_with_error "You must provide a name, summary, and description.",
    #     'new', true, false
    #   return
    # end

    ## Create the new entry.
    begin
      ActiveRecord::Base.transaction do
        @analysis.save!
        respond_with_success get_redirect_path(analysis_path(@analysis))
      end
    rescue => e
      respond_with_error "There was an error saving the analysis entry: #{e}.",
        'new', true, false
    end
  end

  ## Updates a analysis entry. Takes all the usual parameters. The tags,
  ## web_resources, and examples may include "remove" fields along with an
  ## id, which will cause the resource to be disassociated with this project
  ## and deleted altogether if the resource isn't associated with another
  ## vertical entry.
  def update
    begin
      ActiveRecord::Base.transaction do
        @analysis.update(@data.permit(:name, :description, :summary, :thumbnail))
        @analysis.save!
        @analysis.reindex_associations

        respond_with_success get_redirect_path(analysis_path(@analysis))
      end
    rescue => e
      #puts "#{e.message} #{e.backtrace.join("\n")}"
      respond_with_error "There was an error updating the analysis entry: #{e}",
        'edit', true, false
    end  
  end

  ## Deletes the analysis page and any resources connected only to it.
  def destroy
    begin
      ActiveRecord::Base.transaction do

        ## Remove connected resources.
        destroy_isolated_resources(@analysis)
        @analysis.delete_from_connection
        @analysis.destroy!

        flash[:success] = "Page removed."
        redirect_to analyses_path
      end
    rescue => e
      respond_with_error "There was an error removing the analysis entry.",
        new_analysis_path
    end
  end

  def connect
    begin
      @vertical.analyses << @analysis
      @vertical.save!
      @analysis.reload
      @analysis.save!
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The analysis could not be associated with the "+
        "requested vertical.", @redirect_path
    end
  end

  def disconnect
    begin
      if @vertical.analyses.exists?(id: @analysis.id)
        @vertical.analyses.delete(@analysis)
        @vertical.save! 
        @analysis.reload
        @analysis.save!
      end
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The analysis could not be disassociated with the"+
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
        @data = params.require(:analysis).permit(:name, :summary, :description,
          :thumbnail, 
          :bootsy_image_gallery_id,
          tags: [:id, :text, :remove], 
          web_resources: [:id, :url, :description, :remove], 
          examples: [:id, :title, :description, :software_id, :dataset_id,
            :analysis_id, :remove])
      rescue => e
        respond_with_error "Required parameters not supplied.", root_path
      end
    end


    ## Gets the analysis specified by the id in the parameters. If it doesn't
    ## exist, a 404 page is displayed.
    def get_analysis
      @analysis = Analysis.find_by(id: params.require(:id))
      if @analysis.nil?
        error = "No analysis with the specified id exists."
        respond_to do |format|
          format.json {render json: {success: false, error: error}}
          format.html do
            render file: "#{Rails.root}/public/404.html" , status: 404
          end
        end
      end
    end
end
