module ApplicationHelper

  DEFAULT_TITLE = "Alice"

  ## Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = DEFAULT_TITLE
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end


  ## Removes all tags, web resources, and examples connected to the given entry 
  ## instance if they are not connected to any other entries.
  ## @param entry The entry (e.g., Software instance) to destroy resources for.
  def destroy_isolated_resources(entry)
    entry.tags.each{|tag| tag.destroy_if_isolated(1)}
    entry.web_resources.each{|resource| resource.destroy_if_isolated(1)}
    entry.examples.each{|example| example.destroy_if_isolated(1)}
  end


  ## Updates/creates new examples extracted from @data.
  ##
  ## @param vertical The vertical instance to update.
  ## @param remove Whether to handle removals.
  def update_examples(vertical, remove=false)
    if @data.key? :examples
      @data[:examples].each do |example_data|
        ## Create example.
        if example_data.key? :id
          example = Example.find_by(id: example_data[:id])

          ## Delete the example if necessary.
          if remove and example_data.key? :remove and 
              vertical.examples.exists?(id: example.id)
            example.destroy_if_isolated(1)
            vertical.examples.delete(example)

          else
            ## Update the example if necessary.
            if example_data.keys.size > 1
              example.update_attributes!(example_data) 
            end

            ## Add the example if it's not already in there.
            unless vertical.examples.exists?(id: example.id)
              vertical.examples << example 
            end
          end
        else
          example = Example.create!(example_data)
          vertical.examples << example
        end
      end
    end
  end

  ## Updates/creates tags extracted from @data.
  ##
  ## @param vertical The vertical instance to update.
  ## @param remove Whether to handle removals.
  def update_tags(vertical, remove=false)
    if @data.key? :tags
      tags = []
      @data[:tags].each do |tag_data|
        if tag_data.key? :id 
          tag = Tag.find_by(id: tag_data[:id])

          ## Remove tag.
          if not tag.nil? and remove and tag_data.key? :remove and 
              vertical.tags.exists?(id: tag.id)
            tag.destroy_if_isolated(1)
            vertical.tags.destroy(tag)

          ## Add existing tag.
          elsif not tag.nil? and not vertical.tags.exists?(id: tag.id)
              vertical.tags << tag
          end

        ## Add new tag.
        elsif tag_data.key? :text
          tag = Tag.find_by(text: tag_data[:text])
          tag = Tag.create! text: tag_data[:text] if tag.nil?
          vertical.tags << tag
        end
      end
    end
  end


  ## Updates/creates new web resources extracted from @data.
  ##
  ## @param vertical The vertical instance to update.
  ## @param remove Whether to handle removals.
  def update_web_resources(vertical, remove=false)
    if @data.key? :web_resources
      web_resources = []
      @data[:web_resources].each do |web_resource_data|
        web_resource = WebResource.find_by(id: web_resource_data[:id])

        if web_resource_data.key? :id

          ## Remove web resource.
          if web_resource_data.key? :remove and 
              vertical.web_resources.exists?(id: web_resource.id)
            web_resource.destroy_if_isolated(1)
            vertical.web_resources.delete(web_resource)

          ## Add or update existing resource.
          else
            ## Update the data accordingly.
            if web_resource_data.keys.size > 1
              web_resource.update_attributes!(web_resource_data)
            end

            unless vertical.web_resources.exists?(web_resource.id)
              vertical.web_resources << web_resource
            end
          end

        ## Create new web resource
        else
          web_resource = WebResource.create!(web_resource_data)
          vertical.web_resources << web_resource
        end

      end
    end
  end

end
