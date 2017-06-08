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

  ## Returns the path to the given vertical.
  def get_vertical_path(vertical)
    if vertical.class == Software
      software_path(vertical)
    elsif vertical.class == Dataset
      dataset_path(vertical)
    elsif vertical.class == Analysis
      analysis_path(vertical)
    end
  end

  ##############################################################################
  ## The following generate paths for vertical-examples.
  def new_vertical_example_path(vertical)
    "#{get_vertical_path(vertical)}/examples/new"
  end

  def edit_vertical_example_path(vertical, example)
    "#{get_vertical_path(vertical)}/examples/#{example.id}/edit"
  end

  def vertical_example_path(vertical, example)
    "#{get_vertical_path(vertical)}/examples/#{example.id}"
  end

  def vertical_example_index_path(vertical)
    "#{get_vertical_path(vertical)}/examples"
  end
  ##############################################################################

  ##############################################################################
  ## The following generate paths for vertical-web_resources.
  def new_vertical_web_resource_path(vertical)
    "#{get_vertical_path(vertical)}/web_resources/new"
  end

  def edit_vertical_web_resource_path(vertical, web_resource)
    "#{get_vertical_path(vertical)}/web_resources/#{web_resource.id}/edit"
  end

  def vertical_web_resource_path(vertical, web_resource)
    "#{get_vertical_path(vertical)}/web_resources/#{web_resource.id}"
  end

  def vertical_web_resource_index_path(vertical)
    "#{get_vertical_path(vertical)}/web_resources"
  end
  ##############################################################################


  ##############################################################################
  ## The following generate paths for vertical-tag.
  def new_vertical_tag_path(vertical)
    "#{get_vertical_path(vertical)}/tags/new"
  end

  def edit_vertical_tag_path(vertical, tag)
    "#{get_vertical_path(vertical)}/tags/#{tag.id}/edit"
  end

  def vertical_tag_path(vertical, tag)
    "#{get_vertical_path(vertical)}/tags/#{tag.id}"
  end

  def vertical_tag_index_path(vertical)
    "#{get_vertical_path(vertical)}/tags"
  end
  ##############################################################################


  ## For keeping bootsy options consistent.
  def bootsy_editing_options()
    {font_styles: false, html: true}
  end

end
