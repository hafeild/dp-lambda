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

end
