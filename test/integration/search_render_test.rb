require 'test_helper'
require 'erb'
class SearchRenderTest < ActionDispatch::IntegrationTest

  def setup
    reindex
  end

  ##############################################################################
  ## Test each vertical to make sure that the correct results show up for
  ## each one.
  
  test "perform general searches" do 
    
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
  ## Test advanced search.
  
  test "perform an advanced search" do
    get '/search/software', params: {nq: "green", advanced: "true"}
    
    assert_template "search/show"
    assert_select ".search-result", count: 3
    assert_select ".advanced-search-summary", count: 1 do 
      assert_select "td", "Name", count: 1
    end
    assert_select "input[name=\"nq\"][value=\"green\"]", count: 1
    assert_select "input[name=\"sq\"][value=\"\"]", count: 1
    assert_select "input[name=\"dq\"][value=\"\"]", count: 1
    
    get '/search/software', params: {sq: "green", advanced: "true"}
    assert_template "search/show"
    assert_select ".search-result", count: 3
    assert_select ".advanced-search-summary", count: 1 do 
      assert_select "td", "Summary", count: 1
    end
      assert_select "input[name=\"nq\"][value=\"\"]", count: 1
    assert_select "input[name=\"sq\"][value=\"green\"]", count: 1
    assert_select "input[name=\"dq\"][value=\"\"]", count: 1
    
    get '/search/software', params: {dq: "green", advanced: "true"}
    assert_template "search/show"
    assert_select ".search-result", count: 3
    assert_select ".advanced-search-summary", count: 1 do 
      assert_select "td", "Description", count: 1
    end
    assert_select "input[name=\"nq\"][value=\"\"]", count: 1
    assert_select "input[name=\"sq\"][value=\"\"]", count: 1
    assert_select "input[name=\"dq\"][value=\"green\"]", count: 1
    
    get '/search/software', params: {nq: "green", sq: "green", dq: "green", 
      advanced: "true"}
    assert_template "search/show"
    assert_select ".search-result", count: 9
    assert_select ".advanced-search-summary", count: 1 do 
      assert_select "td", "Name", count: 1
      assert_select "td", "Summary", count: 1
      assert_select "td", "Description", count: 1
    end
    assert_select "input[name=\"nq\"][value=\"green\"]", count: 1
    assert_select "input[name=\"sq\"][value=\"green\"]", count: 1
    assert_select "input[name=\"dq\"][value=\"green\"]", count: 1
    
    get '/search/software', params: {nq: "green", sq: "green", dq: "green", 
      advanced: "true", all: "true"}
    
    assert_template "search/show"
    assert_select ".search-result", count: 0
    assert_select ".advanced-search-summary", count: 1 do 
      assert_select "td", "Name", count: 1
      assert_select "td", "Summary", count: 1
      assert_select "td", "Description", count: 1
    end
    assert_select "input[name=\"nq\"][value=\"green\"]", count: 1
    assert_select "input[name=\"sq\"][value=\"green\"]", count: 1
    assert_select "input[name=\"dq\"][value=\"green\"]", count: 1
    assert_select "input[name=\"vertical\"][value=\"software\"]:checked", count: 1
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