class ExamplesController < ApplicationController
  before_action :logged_in_user, except: [:show]
  before_action :user_can_edit, except: [:show]
  before_action :get_simple_params, only: [:new, :edit]
  before_action :get_params, except: [:index, :show, :edit, :new, 
    :connect, :disconnect]
  before_action :get_example, except: [:index]
  before_action :get_verticals
  before_action :get_redirect_path

  def show
  end

  def new
  end

  def edit
  end

  def index
    @examples = Example.all.sort_by{|e| e.title}
  end

  def create
    begin
        throw Exception("No vertical specified!") if @vertical.nil?
        @example = Example.create! @params
        @vertical.examples << @example
        @vertical.save!
      respond_with_success @redirect_path
    rescue
      respond_with_error "The example could not be created.", @redirect_path
    end
  end

  def update
    begin
      @example.update_attributes! @params
      respond_with_success @redirect_path
    rescue
      respond_with_error "The example could not be updated.", @redirect_path
    end
  end

  def destroy
  end

  def connect
    begin
      @vertical.examples << @example
      @vertical.save!
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The example could not be associated with the "+
        "requested vertical.", @redirect_path
      
    end
  end

  def disconnect
    begin
      if @vertical.examples.exists?(id: @example.id)
        @example.destroy_if_isolated(1)
        @vertical.examples.delete(@example)
        @vertical.save! 
      end
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The example could not be disassociated with the "+
        "requested vertical.", @redirect_path
    end
  end

  private

    def get_simple_params
      @params = params.permit(:software_id, :redirect_path, :id)
    end


    ## Extracts the allowed parameters into a global named @data.
    def get_params
      begin
        @params = params.require(:example).permit(:title, :description)
      rescue => e
        respond_with_error "Required parameters not supplied."
      end
    end

    def get_example
      if params.key? :id
        @example = Example.find(params[:id])
      else
        @example = Example.new
      end
    end

    ## Gets the associated software or other vertical.
    def get_verticals
      begin
        @vertical = nil
        @software = nil

        if params.key? :software_id
          @software = Software.find(params[:software_id]) 
          @vertical = @software
        end

      rescue
        error = "Invalid vertical id given."

      end
    end


    ## Gets the back path (where to go on submit or cancel).
    def get_redirect_path
      if params.key? :redirect_path
        @redirect_path = params[:redirect_path]
      elsif not @software.nil?
        @redirect_path = software_path(@software.id)
      else
        @redirect_path = root_path
      end
    end


end