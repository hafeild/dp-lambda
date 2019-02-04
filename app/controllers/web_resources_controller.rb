class WebResourcesController < ApplicationController
  before_action :logged_in_user, except: [:show]
  before_action :user_can_edit, except: [:show]
  before_action :get_simple_params, only: [:new, :edit]
  before_action :get_params, except: [:index, :show, :edit, :new, 
    :connect, :disconnect]
  before_action :get_web_resource
  before_action :get_verticals
  before_action :get_redirect_path

  def show
  end

  def new
  end

  def edit
  end

  def index
    @web_resources = WebResource.all.sort_by{|e| e.description}
  end

  def create
    @web_resource = WebResource.new @params
    begin
        throw Exception("No vertical specified!") if @vertical.nil?
        @web_resource.save!
        @vertical.web_resources << @web_resource
        @vertical.save!
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The web resource could not be created: #{e}.", 
        'new', true, false
    end
  end

  def update
    begin
      @web_resource.update! @params
      respond_with_success @redirect_path
    rescue => e 
      # puts e.message
      respond_with_error "The web resource could not be updated: #{e}.", 
        'edit', true, false
    end
  end

  def destroy
  end

  def connect
    begin
      @vertical.web_resources << @web_resource
      @vertical.save!
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The web resource could not be associated with the "+
        "requested vertical.", @redirect_path
    end
  end

  def disconnect
    begin
      if @vertical.web_resources.exists?(id: @web_resource.id)
        @web_resource.destroy_if_isolated(1)
        @vertical.web_resources.delete(@web_resource)
        @vertical.save! 
      end
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The web resource could not be disassociated with the"+
        " requested vertical.", @redirect_path
    end
  end

  private

    def get_simple_params
      @params = params.permit(:software_id, :redirect_path, :id)
    end


    ## Extracts the allowed parameters into a global named @data.
    def get_params
      begin
        @params = params.require(:web_resource).permit(:url, :description)
      rescue => e
        respond_with_error "Required parameters not supplied."
      end
    end

    def get_web_resource
      if params.key? :id
        @web_resource = WebResource.find(params[:id])
      else
        @web_resource = WebResource.new
      end
    end
end