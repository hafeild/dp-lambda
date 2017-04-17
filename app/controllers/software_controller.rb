class SoftwareController < ApplicationController
  before_action :logged_in_user, only: [:create, :edit, :update, :destroy]
  before_action :get_params, only: [:create, :edit, :update]

  def new
  end

  def edit
  end

  ## Creates a new software entry. It assumes the following parameter structure:
  ##
  ##  id: ...
  ##  software: {
  ##    name: ...
  ##    summary: ...
  ##    description: ...
  ##    tags*: [text, ...]
  ##    web_resources*: {
  ##      id*: ...
  ##      url**: ...
  ##      description**: ...
  ##    }
  ##    examples*: {
  ##      id*: ...
  ##      title**: ...
  ##      description**: ...
  ##      software_id*: ...
  ##      analyses_id*: ...
  ##      dataset_id*: ...
  ##    }
  ## }
  ##    
  ## * is optional; in the case that ids are supplied, any existing element
  ##   will have its information updated with the other values passed in. 
  ## ** optional in the presence of an optional id, required otherwise.
  def create

    ## Make sure we have the required fields.
    if not @data.key?(:name) or @data[:name].empty? or 
        not @data.key?(:summary) or @data[:summary].empty? or 
        not @data.key?(:description) or @data[:description].empty?
      flash[:danger] = "You must provide a name, summary, and description."
      redirect_back_or new_software_path
      return
    end


    ## Create the new entry.
    begin
      ActiveRecord::Base.transaction do
        software = Software.new(
          creator: current_user, name: @data[:name], summary: @data[:summary], 
          description: @data[:description]
        )

        ## Process tags.
        if @data.key? :tags
          tags = []
          @data[:tags].each do |tag_text|
            ## Create tag.
            tag = Tag.find_by(text: tag_text)
            if tag.nil?
              tag = Tag.create! text: tag_text
            end
            software.tags.append(tag)
          end
        end

        ## Process web resources.
        if @data.key? :web_resources
          web_resources = []
          @data[:web_resources].each do |web_resource_data|

            if web_resource_data.key?(:id)
              web_resource = WebResource.find_by(id: web_resource_data[:id])
              ## Update the data accordingly.
              if web_resource_data.keys.size > 1
                web_resource.update_attributes!(web_resource_data)
              end
            else
              ## Create new web resource
              web_resource = WebResource.create!(web_resource_data)
            end
            software.web_resources.append(web_resource)
          end
        end

        ## Process examples.
        if @data.key? :examples
          @data[:examples].each do |example_data|
            ## Create example.
            if example_data.key?(:id)
              example = Example.find_by(id: example_data[:id])
              if example_data.keys.size > 1
                example.update_attributes!(example_data) 
              end
            else
              example = Example.create!(example_data)
            end
            software.examples.append(example)
          end
        end

        software.save!
        # render plain: "#{@data.to_h.to_json} -- #{params.require(:software).to_unsafe_h.to_json}"
        redirect_to software_path(software.id)
      end
    rescue => e
      flash[:danger] = "There was an error saving the software entry."
      #redirect_back_or new_software_path
      render plain: e
    end
  end

  def update
  end

  def destroy
  end

  private

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "You must be logged in to modify content."
        redirect_back_or root_url
      end
    end

    def get_params
      @data = params.require(:software).permit(:name, :summary, :description,
        :thumbnail, 
        tags: [], 
        web_resources: [:id, :url, :description], 
        examples: [:id, :title, :description, :software_id, :analysis_id,
          :dataset_id])
    end


end
