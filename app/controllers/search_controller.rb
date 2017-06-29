class SearchController < ApplicationController  
  before_action :get_vertical_map
  before_action :get_redirect_path
  
  def show    
    # begin
      @search_params = params.permit(:vertical, :q)
      @vertical = @search_params.require(:vertical)
      
      ## Check that vertical is valid:
      throw Exception.new('Invalid vertical.') unless valid_vertical(@vertical)
      
      @query = @search_params.require(:q).to_s.downcase
      
      
      query_body = Proc.new do |dsl|
        dsl.keywords @query
        dsl.paginate page: 1, per_page: 10
      end
      
      start_time = Time.now
      if @vertical == 'all'
        @search = Sunspot.search Assignment, Software, &query_body
      else
        @search = Sunspot.search @vertical_map[@vertical], &query_body
      end
      end_time = Time.now
      
      @query_seconds = (end_time - start_time)/1000.0
      
      render 'show'
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
