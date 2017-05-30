class ExamplesController < ApplicationController
  before_action :logged_in_user, except: [:index, :show]
  before_action :user_can_edit, except: [:index, :show]
  before_action :get_simple_params, only: [:new, :edit]
  before_action :get_params, except: [:index, :show, :edit, :new, 
    :connect, :disconnect]
  before_action :get_example, except: [:index, :show, :connect]
  before_action :get_verticals, except: [:index, :show]
  before_action :get_redirect_path, except: [:index, :show, :new, :edit]

  def new
  end

  def edit
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
      @example.update_attributes! @params.permit(:url, :description)
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
    rescue
      respond_with_error "The example could not be associated to the "+
        "requested vertical.", @redirect_path
      
    end
  end

  def disconnect
    begin
      if @vertical.examples.exists?(id: @example.id)
        @example.destroy_if_isolated(1)
      end
      respond_with_success @redirect_path
    rescue Exception => e
      respond_with_error "The example could not be disassociated with the "+
        "requested vertical. #{e}", @redirect_path
    end
  end

  private

    def get_simple_params
      @params = params.permit(:software_id, :redirect_path, :id)
    end


    ## Extracts the allowed parameters into a global named @data.
    def get_params
      begin
        @params = params.require(:example).permit(:title, :description,
          :software_id)
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