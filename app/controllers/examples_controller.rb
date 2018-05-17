class ExamplesController < ApplicationController
  before_action :logged_in_user, except: [:show]
  before_action :user_can_edit, except: [:show]
  before_action :get_simple_params, only: [:new, :edit]
  before_action :get_params, except: [:index, :show, :edit, :new, 
    :connect, :disconnect, :destroy]
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
        @example = Example.create!(title: @params[:title], 
          summary: @params[:summary], description: @params[:description],
          creator: current_user)

        unless @vertical.nil?
          @vertical.examples << @example
          @vertical.save!
        end

      respond_with_success get_redirect_path(example_path(@example))
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
    begin
      ActiveRecord::Base.transaction do

        ## Remove connected resources.
        destroy_isolated_resources(@example)

        @example.destroy!

        flash[:success] = "Page removed."
        redirect_to examples_path
      end
    rescue => e
      respond_with_error "There was an error removing the example entry.",
        example_path(@example)
    end
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
        @params = params.require(:example).permit(
          :title, :summary, :description, :bootsy_image_gallery_id
        )
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
end