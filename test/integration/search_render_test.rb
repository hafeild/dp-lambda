require 'test_helper'
require 'erb'
class SearchRenderTest < ActionDispatch::IntegrationTest

  def setup
    reindex
  end


  ##############################################################################
  ## Test that linked verticals show up in results using keywords associated
  ## with the original vertical, but stop showing up if delinked or if the
  ## original vertical is removed.
  
  test "example linked verticals show up in results" do 
    log_in_as users(:foo)

    example = examples(:three)
    assignment = assignments(:four)
    dataset = datasets(:two)
    software = software(:two)

    expected_results = [
      ['example', example],
      ['assignment', assignment],
      ['dataset', dataset],
      ['software', software]
    ]
    
    ## Intially, only example :three should be retrieved.
    get '/search/all', params: {q: "ttttt" }
    
    assert_template "search/show"
    assert_select ".search-result", count: 1

    assert_select ".search-result[data-rank=\"1\"]", count: 1 do
      assert_select "div[data-example-id=\"#{example.id}\"]", count: 1
    end
      
    ## After associating datasets :two, software :two, and assignment :four,
    ## all three should be retrieved.
    expected_results[1..-1].each do |x|
      @request.env['CONTENT_TYPE'] = 'application/json'
      post vertical_vertical_path(x[1], example)+'.json'
      example.reload
      result = JSON.parse(@response.body)
      assert result['success'], result

      x[1].reload
      assert x[1].examples.exists?(id: example.id)
    end
    example.reload
    assert example.assignments.exists?(id: assignment.id)
    assert example.software.exists?(id: software.id)
    assert example.datasets.exists?(id: dataset.id)

    get '/search/all', params: {q: "ttttt" }
    assert_template "search/show"
    assert_select ".search-result", count: 4
    expected_results.each do |x|
      assert_select "div[data-#{x[0]}-id=\"#{x[1].id}\"]", count: 1
    end

    ## Example :three and assignment :four should be retrieved for text in
    ## assignment :two.
    get '/search/all', params: {q: "assignmentassignment" }
    assert_template "search/show"
    assert_select ".search-result", count: 2
    assert_select "div[data-example-id=\"#{example.id}\"]", count: 1
    assert_select "div[data-assignment-id=\"#{assignment.id}\"]", count: 1
    
    ## Updating example :three should affect associated verticals.
    @request.env['CONTENT_TYPE'] = 'application/json'
    patch example_path(example)+'.json', params: {example: {
      summary: "ttt"
    }}
    get '/search/all', params: {q: "ttttt" }
    assert_template "search/show"
    assert_select ".search-result", count: 0
    get '/search/all', params: {q: "ttt" }
    assert_template "search/show"
    assert_select ".search-result", count: 4
    expected_results.each do |x|
      assert_select "div[data-#{x[0]}-id=\"#{x[1].id}\"]", count: 1
    end

    ## After de-associating datasets :two, it should no longer be retrieved.
    delete vertical_vertical_path(example, dataset), params: {}
    get '/search/all', params: {q: "ttt" }
    assert_template "search/show"
    assert_select ".search-result", count: 3
    assert_select "div[data-dataset-id=\"#{dataset.id}\"]", count: 0
    
    ## After deleting example :three, nothing should be retrieved for the query.
    delete example_path(example), params: {}
    get '/search/all', params: {q: "ttt" }
    assert_template "search/show"
    assert_select ".search-result", count: 0

  end
  
  ##############################################################################

  ##############################################################################
  ## Test that linked verticals show up in results using keywords associated
  ## with the original vertical, but stop showing up if delinked or if the
  ## original vertical is removed.
  
  test "analysis linked verticals show up in results" do 
    log_in_as users(:foo)

    analysis = analyses(:three)
    example = examples(:three)
    assignment = assignments(:four)
    software = software(:two)

    expected_results = [
      ['analysis', analysis],
      ['example', example],
      ['assignment', assignment],
      ['software', software]
    ]
    
    ## Intially, only analysis :three should be retrieved.
    get '/search/all', params: {q: "analysis3analysis3" }
    
    assert_template "search/show"
    assert_select ".search-result", count: 1

    assert_select ".search-result[data-rank=\"1\"]", count: 1 do
      assert_select "div[data-analysis-id=\"#{analysis.id}\"]", count: 1
    end
      
    ## After associating example :three, software :two, and 
    ## assignment :four, all four should be retrieved.
    expected_results[1..-1].each do |x|
      @request.env['CONTENT_TYPE'] = 'application/json'
      post vertical_vertical_path(x[1], analysis)+'.json'
      result = JSON.parse(@response.body)
      assert result['success'], result

      x[1].reload
      assert x[1].analyses.exists?(id: analysis.id)
    end
    analysis.reload
    assert analysis.assignments.exists?(id: assignment.id)
    assert analysis.software.exists?(id: software.id)
    assert analysis.examples.exists?(id: example.id)

    get '/search/all', params: {q: "analysis3analysis3" }
    assert_template "search/show"
    expected_results.each do |x|
      assert_select "div[data-#{x[0]}-id=\"#{x[1].id}\"]", count: 1
    end
    assert_select ".search-result", count: 4

    ## Example :three and assignment :four should be retrieved for text in
    ## assignment :two.
    get '/search/all', params: {q: "assignmentassignment" }
    assert_template "search/show"
    assert_select "div[data-analysis-id=\"#{analysis.id}\"]", count: 1
    assert_select "div[data-assignment-id=\"#{assignment.id}\"]", count: 1
    assert_select ".search-result", count: 2
    
    ## Updating example :three should affect associated verticals.
    @request.env['CONTENT_TYPE'] = 'application/json'
    patch analysis_path(analysis)+'.json', params: {analysis: {
      summary: "analysis3analysis3analysis3"
    }}
    get '/search/all', params: {q: "analysis3analysis3" }
    assert_template "search/show"
    assert_select ".search-result", count: 0
    get '/search/all', params: {q: "analysis3analysis3analysis3" }
    assert_template "search/show"
    assert_select ".search-result", count: 4
    expected_results.each do |x|
      assert_select "div[data-#{x[0]}-id=\"#{x[1].id}\"]", count: 1
    end

    ## After de-associating example :three, it should no longer be retrieved.
    delete vertical_vertical_path(example, analysis), params: {}
    get '/search/all', params: {q: "analysis3analysis3analysis3" }
    assert_template "search/show"
    assert_select ".search-result", count: 3
    assert_select "div[data-example-id=\"#{example.id}\"]", count: 0
    
    ## After deleting analysis :two, nothing should be retrieved for the query.
    delete analysis_path(analysis), params: {}
    get '/search/all', params: {q: "analysis3analysis3analysis3" }
    assert_template "search/show"
    assert_select ".search-result", count: 0

  end
  
  ##############################################################################


  ##############################################################################
  ## Test that linked verticals show up in results using keywords associated
  ## with the original vertical, but stop showing up if delinked or if the
  ## original vertical is removed.
  
  test "assignment linked verticals show up in results" do 
    log_in_as users(:foo)

    assignment = assignments(:four)
    assignment2 = assignments(:two)
    analysis = analyses(:three)
    example = examples(:three)
    software = software(:two)
    dataset = datasets(:two)

    expected_results = [
      ['assignment', assignment],
      ['assignment', assignment2],
      ['analysis', analysis],
      ['example', example],
      ['software', software],
      ['dataset', dataset]
    ]
    
    ## Intially, only assignment :four should be retrieved.
    get '/search/all', params: {q: "assignmentassignment" }
    
    assert_template "search/show"
    assert_select ".search-result", count: 1

    assert_select ".search-result[data-rank=\"1\"]", count: 1 do
      assert_select "div[data-assignment-id=\"#{assignment.id}\"]", count: 1
    end
      
    ## After associating example :three, software :two, dataset :two, and 
    ## analysis :three, all five should be retrieved.
    expected_results[1..-1].each do |x|
      @request.env['CONTENT_TYPE'] = 'application/json'
      post vertical_vertical_path(assignment, x[1])+'.json'
      result = JSON.parse(@response.body)
      assert result['success'], result

      x[1].reload
      if x[0] == 'assignment'
        assert x[1].assignments_related_from.exists?(id: assignment.id)
      else
        assert x[1].assignments.exists?(id: assignment.id)
      end
    end
    assignment.reload
    assert assignment.assignments_related_to.exists?(id: assignment2.id)
    assert assignment.analyses.exists?(id: analysis.id)
    assert assignment.software.exists?(id: software.id)
    assert assignment.examples.exists?(id: example.id)
    assert assignment.datasets.exists?(id: dataset.id)

    get '/search/all', params: {q: "assignmentassignment" }
    assert_template "search/show"
    expected_results.each do |x|
      assert_select "div[data-#{x[0]}-id=\"#{x[1].id}\"]", count: 1
    end
    assert_select ".search-result", count: 6

    ## Analysis :three and assignment :four should be retrieved for text in
    ## analysis :three.
    get '/search/all', params: {q: "analysis3analysis3" }
    assert_template "search/show"
    assert_select "div[data-analysis-id=\"#{analysis.id}\"]", count: 1
    assert_select "div[data-assignment-id=\"#{assignment.id}\"]", count: 1
    assert_select ".search-result", count: 2
    
    ## Updating assignment :four should affect associated verticals.
    @request.env['CONTENT_TYPE'] = 'application/json'
    patch assignment_path(assignment)+'.json', params: {assignment: {
      summary: "assignmentassignmentassignment"
    }}
    get '/search/all', params: {q: "assignmentassignment" }
    assert_template "search/show"
    assert_select ".search-result", count: 0
    get '/search/all', params: {q: "assignmentassignmentassignment" }
    assert_template "search/show"
    assert_select ".search-result", count: 6
    expected_results.each do |x|
      assert_select "div[data-#{x[0]}-id=\"#{x[1].id}\"]", count: 1
    end

    ## After de-associating example :three, it should no longer be retrieved.
    delete vertical_vertical_path(example, assignment), params: {}
    get '/search/all', params: {q: "assignmentassignmentassignment" }
    assert_template "search/show"
    assert_select ".search-result", count: 5
    assert_select "div[data-example-id=\"#{example.id}\"]", count: 0
    
    ## After deleting assignment :four, nothing should be retrieved for the query.
    delete assignment_path(assignment), params: {}
    get '/search/all', params: {q: "assignmentassignmentassignment" }
    assert_template "search/show"
    assert_select ".search-result", count: 0

  end
  
  ##############################################################################



  ##############################################################################
  ## Test each vertical to make sure that the correct results show up for
  ## each one.
  
  test "perform general searches" do 

    expected_results = [
      ['assignment', assignments(:two).id],
      ['dataset', datasets(:two).id],
      ['software', software(:two).id],
      ['analysis', analyses(:one).id],
      ['dataset', datasets(:one).id],
      ['software', software(:one).id],
      ['assignment', assignments(:one).id],
      ['example', examples(:two).id]
    ]
    
    
    get '/search/all', params: {q: "lion" }
    
    assert_template "search/show"
    
    # print @response.body

    expected_results.each_with_index do |x, i|
      assert_select ".search-result[data-rank=\"#{i+1}\"]", count: 1 do
        assert_select "div[data-#{x[0]}-id=\"#{x[1]}\"]", count: 1
      end
    end

    assert_select ".search-result", count: expected_results.size
    
    
    get '/search/software', params: {q: "lion" }
    
    assert_template "search/show"
    assert_select ".search-result", count: 2
    
    assert_select ".search-result[data-rank=\"1\"]", count: 1 do
      assert_select "div[data-software-id=\"#{software(:two).id}\"]", count: 1
    end
    
    assert_select ".search-result[data-rank=\"2\"]", count: 1 do
      assert_select "div[data-software-id=\"#{software(:one).id}\"]", count: 1
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
    assert_select "input[name=\"vertical\"][value=\"software\"]" do |elm|
        assert elm.attr("checked").present?
    end
  end
  ##############################################################################
  
  
  
  private
  
    def reindex
      Assignment.reindex
      Analysis.reindex
      Software.reindex
      Dataset.reindex
      Example.reindex
    end
end
