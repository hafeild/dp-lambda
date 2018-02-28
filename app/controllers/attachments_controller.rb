class AttachmentsController < ApplicationController
  before_action :logged_in_user, except: [:index]
  before_action :user_can_edit, except: [:index]
  before_action :get_redirect_path
  before_action :get_file_attachment, only: [:create]
  before_action :get_attachment_id, only: [:destroy]
  before_action :get_verticals_or_example
  
  def index
    @attachments = Attachment.all()
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        ## Create the attachment.
        attachment = Attachment.create!(file_attachment: @file_attachment,
          uploaded_by: @current_user)
        ## Link it to whichever vertical/example was input.
        @vertical.attachments << attachment 
        if exceeds_project_max_attachment_size @vertical
          raise "Maximum attachment size "+
            "(#{ENV['VERTICAL_MAX_TOATAL_ATTACHMENTS_SIZE']}) MiB exceeded."
        end
        @vertical.save!
      end
      
      respond_with_success get_vertical_path(@vertical)
    rescue => e
      respond_with_error "There was an error saving the attachment. #{e}", 
        @redirect_path
    end
  end
  
  def destroy
    begin
      Attachment.find(@attachment_id).destroy!
      respond_with_success get_vertical_path @vertical
    rescue => e
      respond_with_error "There was an error removing the attachment.", 
        @redirect_path
    end
  end
  
  private
  
    def get_attachment_id
      begin
        @attachment_id = params.require(:id)
      rescue => e
        respond_with_error "Error: not attachment id specified.", @redirect_path
      end
    end
  
    def get_file_attachment
      begin
        @file_attachment = params.require(:attachment).require(:file_attachment)
      rescue => e 
        respond_with_error "Error: no attachment provide.", @redirect_path
      end
    end
  
    ## Checks for a parameter of the form <vertical>_id (e.g., software_id)
    ## or example_id. Renders an error if not found.
    def get_verticals_or_example
      get_verticals
      
      begin
        if @vertical_form_id.nil? and params.key? :example_id
          @vertical = Example.find(params[:example_id])
          @vertical_form_id = :example_id
        end
      rescue
        @vertical = nil
      end
      
      if @vertical.nil?
        respond_with_error "Attachments must be associated with a vertical or example.", 
          @redirect_path
      end
    end
    
    def exceeds_project_max_attachment_size vertical
      total_size = 0
      vertical.attachments.each do |attachment|
        total_size += attachment.file_attachment_file_size
      end
      total_size > Rails.configuration.VERTICAL_MAX_TOATAL_ATTACHMENTS_SIZE
    end
  
end