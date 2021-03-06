class ExamplesController < ApplicationController
  before_action :logged_in_user, except: [:show,:index]
  before_action :user_can_edit, except: [:show,:index]
  before_action :get_simple_params, only: [:new, :edit]
  before_action :get_params, only: [:create, :update]
  before_action :get_example, except: [:index, :connect_index]
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

  def connect_index
    @examples = Example.all.sort_by { |e| e.title }
    if @vertical.class == Example
      @examples.delete(@vertical)
    end
  end

  def create
    @params[:creator] = current_user
    @example = Example.new(@params)
    begin
        # if  @params[:summary].nil? or  @params[:summary].size == 0
        #   raise "Summary must be present and non-empty."
        # end
        @example.save!

        unless @vertical.nil?
          @vertical.examples << @example
          @vertical.save!
        end

      respond_with_success get_redirect_path(example_path(@example))
    rescue => e
      respond_with_error "The example could not be created: #{e}.", 'new', 
        true, false
    end
  end

  def update

    begin
      @example.update! @params
      @example.reindex_associations
      respond_with_success get_redirect_path(example_path(@example))
    rescue => e
      # puts "#{e.message} #{e.backtrace.join("\n")}"
      respond_with_error "The example could not be updated.", 
        'edit', true, false
    end
  end

  def destroy
    begin
      ActiveRecord::Base.transaction do

        ## Remove connected resources.
        destroy_isolated_resources(@example)
        @example.delete_from_connection
        @example.destroy!

        flash[:success] = "Page removed."
        redirect_to examples_path
      end
    rescue => e
      #puts "#{e.message} #{e.backtrace.join("\n")}"
      respond_with_error "There was an error removing the example entry.",
        example_path(@example)
    end
  end

  def connect
    begin
      unless @vertical.examples.exists?(id: @example.id)
        @vertical.examples << @example
        @vertical.save!
        @example.reload
        @example.save!
      end
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
        @example.reload
        @example.save!
      end
      respond_with_success @redirect_path
    rescue => e
      puts "#{e.backtrace}: #{e.message} (#{e.class})"
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
          :title, :summary, :description, :bootsy_image_gallery_id, :thumbnail
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