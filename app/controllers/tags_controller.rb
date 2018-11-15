class TagsController < ApplicationController
  before_action :logged_in_user, except: [:show]
  before_action :user_can_edit, except: [:show]
  before_action :get_simple_params, only: [:new, :edit]
  before_action :get_params, except: [:index, :show, :edit, :new, 
    :connect, :disconnect]
  before_action :get_tag, except: [:create]
  before_action :get_verticals
  before_action :get_redirect_path

  def show
  end

  def new
  end

  def edit
  end

  def index
    @tags = Tag.all.sort_by{|e| e.text}
  end

  ## This is a little different from other resource controllers' create
  ## method; here, we split the tag text by comma and treat each chunk as
  ## it's own tag. Text that already exists as a tag isn't recreated, but is
  ## linked to the vertical requesting the creation.
  def create
    begin
      throw Exception("No vertical specified!") if @vertical.nil?
      ActiveRecord::Base.transaction do

        @params[:text].split(/\s*,\s*/).each do |tag_text|
          next if tag_text.size == 0
          tag_text.downcase!
          tag = Tag.find_by(text: tag_text) || Tag.create!(text: tag_text)
          @vertical.tags << tag
          @vertical.save!
        end

        respond_with_success @redirect_path
      end
    rescue => e
      respond_with_error("The tag could not be created.", @redirect_path)
    end
  end

  def update
    begin
      @tag.update_attributes!(text: @params[:text].downcase)
      respond_with_success @redirect_path
    rescue
      respond_with_error "The tag could not be updated.", 
        @redirect_path
    end
  end

  def destroy
  end

  def connect
    begin
      @vertical.tags << @tag
      @vertical.save!
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The tag could not be associated with the "+
        "requested vertical.", @redirect_path
    end
  end

  def disconnect
    begin
      if @vertical.tags.exists?(id: @tag.id)
        @tag.destroy_if_isolated(1)
        @vertical.tags.delete(@tag)
        @vertical.save! 
      end
      respond_with_success @redirect_path
    rescue => e
      respond_with_error "The tag could not be disassociated with the"+
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
        @params = params.require(:tag).permit(:text)
      rescue => e
        respond_with_error "Required parameters not supplied."
      end
    end

    def get_tag
      if params.key? :id
        @tag = Tag.find(params[:id])
      else
        @tag = Tag.new
      end
    end


end