class SearchController < ApplicationController  
  before_action :get_vertical_map
  before_action :get_redirect_path
  
  def show    
    # begin
      @search_params = params.permit(:vertical, :q, :cursor, :full_json)
      @vertical = @search_params.require(:vertical)
      
      ## Check that vertical is valid:
      throw Exception.new('Invalid vertical.') unless valid_vertical(@vertical)
      
      @query = @search_params.require(:q).to_s.downcase
      
      ## Other options.
      cursor = get_with_default(@search_params, :cursor, '*')
      full_json = get_with_default(@search_params, :full_json, false)
      
      
      query_body = Proc.new do |dsl|
        dsl.keywords @query
        #dsl.paginate page: 1, per_page: 10
        dsl.paginate :cursor => cursor, per_page: 3
      end
      
      start_time = Time.now
      if @vertical == 'all'
        @search = Sunspot.search( Assignment, Analysis, Software, Dataset, 
          &query_body )
      else
        @search = Sunspot.search @vertical_map[@vertical], &query_body
      end
      end_time = Time.now
      
      @query_seconds = (end_time - start_time)/1000.0
      
      respond_to do |format|
        format.json do 
          render json: {
            success: true, 
            last_page: @search.results.last_page?,
            current_cursor: @search.results.current_cursor,
            next_page_cursor: @search.results.next_page_cursor,
            result_set_html: render_to_string(
                partial: 'search/result_set.html.erb', 
                locals: {search: @search}, formats: [:html])
          }
        end
        format.html { render 'show' }
      end
    # rescue => e 
    #   respond_with_error "There was an error while executing your search: #{e}.", 
    #     @redirect_path
    # end
  end
  
  private  
    def get_vertical_map
      @vertical_map = {
        'all' => nil,
        'assignments' => Assignment,
        'examples' => Example,
        'analyses' => Analysis,
        'datasets' => Dataset,
        'software' => Software
      }
    end
  
  
    def valid_vertical(vertical)
      return @vertical_map.key? vertical
    end
  
end
