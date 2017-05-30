class WebResourcesController < ApplicationController
  before_action :logged_in_user, exclude: [:index, :show]
  before_action :user_can_edit, exclude: [:index, :show]
  before_action :get_params, exclude: [:index, :show]
  before_action :get_verticals, exclude: [:index, :show]
  before_action :get_back_path, exclude: [:index, :show]

  def new
  end

  def edit
  end

  private

    ## Extracts the allowed parameters into a global named @data.
    def get_params
      begin
        @params = params.require(:web_resource).permit(:url, :description,
          :software_id)
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

    ## Gets the associated software or other vertical.
    def get_verticals
      begin
        if @params.key? :software_id
          @vertical = Software.find(@params[:software_id]) 
          @submit_url = software_path @vertical.id
        end

      rescue
        error = "Invalid vertical id given."
        respond_to do |format|
          format.json { render json: {success: false, error: error} }
          format.html do 
            flash[:danger] = error
            redirect_back_or root_path
          end
        end
      end
    end

end