class GalleriesController < ApplicationController
  before_action :logged_in_user, only: [:create, :update, :destroy]
  before_action :user_can_edit, only: [:create, :update, :destroy]
  before_action :get_params, only: [:create, :update]

  def create
    Gallery.create!(@data[:image])
  end

  def update
    Gallery.update!(@data[:image])
  end

  def destroy
    Gallery.find(params[:id]).destroy!
  end



  private
    def get_params
      @data = params.require(:image).permit(:bootsy_image_gallery_id)
    end

end