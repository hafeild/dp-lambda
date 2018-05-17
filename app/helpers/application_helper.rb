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
  end

  ## Returns the path to the given vertical.
  def get_vertical_path(vertical)
    if vertical.class == Software
      software_path(vertical)
    elsif vertical.class == Dataset
      dataset_path(vertical)
    elsif vertical.class == Analysis
      analysis_path(vertical)
    elsif vertical.class == Assignment
      assignment_path(vertical)
    elsif vertical.class == Example
      example_path(vertical)
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


  ##############################################################################
  ## The following generate paths for vertical-attachment.
  def new_vertical_attachment_path(vertical)
    "#{get_vertical_path(vertical)}/attachments/new"
  end

  def edit_vertical_attachment_path(vertical, attachment)
    "#{get_vertical_path(vertical)}/attachments/#{attachment.id}/edit"
  end

  def vertical_attachment_path(vertical, attachment)
    "#{get_vertical_path(vertical)}/attachments/#{attachment.id}"
  end

  def vertical_attachments_path(vertical)
    "#{get_vertical_path(vertical)}/attachments"
  end

  def reorder_vertical_attachments_path(vertical)
    "#{get_vertical_path(vertical)}/attachments/reorder"
  end
  ##############################################################################


  ##############################################################################
  ## The following generate paths for vertical-vertical.
  def vertical_vertical_path(vertical1, vertical2)
    [get_vertical_path(vertical1), vertical2.class.to_s.downcase.pluralize(2), 
      vertical2.id
      ].join("/")
  end

  def edit_vertical_vertical_path(vertical1, vertical2)
    [get_vertical_path(vertical1), vertical2.class.to_s.downcase.pluralize(2), 
      vertical2.id, "edit"
      ].join("/")
  end


  def vertical_vertical_index_path(vertical1, vertical2)
    [get_vertical_path(vertical1), vertical2.class.to_s.downcase.pluralize(2)].join("/")
  end

  ##############################################################################


  ## For keeping bootsy options consistent.
  def bootsy_editing_options()
    {font_styles: false, html: true}
  end

  ## Takes a string and truncates it to the given length. If the original size
  ## is greater than the requested length, ellipses are appended.
  def get_snippet(text, length)
    text.size > length ? "#{text[0..length]}..."  : text
  end

  ## Sorts a given list or collection by the name field of each entry.
  ## Assumes that an entry has a name field (it is not verified).
  def sort_by_name(collection)
    sort_by(collection, :name)
  end


  ## Sorts a given list or collection by the given key of each entry.
  ## Assumes that an entry has a field of name key (it is not verified).
  def sort_by(collection, key)
    collection.sort{|x,y| x[key] <=> y[key]}
  end

  ## For sanitizing user input.
  def sanitize_text(text)
    tags = %w(a b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub 
      sup ins p pre code span div img)
    sanitize(text, tags: tags, attributes: %w(href title src style class alt))
  end

################################################################################




end

