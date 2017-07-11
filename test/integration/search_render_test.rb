require 'test_helper'
require 'erb'
class SearchRenderTest < ActionDispatch::IntegrationTest

  def setup
    reindex
  end

  ##############################################################################
  ## Test each vertical to make sure that the correct results show up for
  ## each one.
  
  test "should display SERP with the correct results in the correct order" do 
    
    expected_results = [
      ['assignment', assignments(:two).id],
      ['dataset', datasets(:two).id],
      ['software', software(:two).id]
    ]
    
    
    get '/search/all', params: {q: "lion" }
    
    assert_template "search/show"
    assert_select ".search-result", count: 3
    
    expected_results.each_with_index do |x, i|
      assert_select ".search-result[data-rank=\"#{i+1}\"]", count: 1 do
        assert_select "div[data-#{x[0]}-id=\"#{x[1]}\"]", count: 1
      end
    end
    
    
    get '/search/software', params: {q: "lion" }
    
    assert_template "search/show"
    assert_select ".search-result", count: 1
    
    assert_select ".search-result[data-rank=\"1\"]", count: 1 do
      assert_select "div[data-software-id=\"#{software(:two).id}\"]", count: 1
    end
    
  end
  
  ##############################################################################
  
  
  ##############################################################################
  ## Test infinite scrolling.
  
  test "infinite scrolling should work" do
    
    
  end
  ##############################################################################
  
  
  ##############################################################################
  ## Test advanced search.
  
  test "advanced search should work" do
  end
  ##############################################################################
  
  
  
  private
  
    def reindex
      Assignment.reindex
      Analysis.reindex
      Software.reindex
      Dataset.reindex
    end
end