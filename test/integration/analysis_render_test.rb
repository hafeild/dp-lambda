require 'test_helper'
require 'erb'
class AnalysisRenderTest < ActionDispatch::IntegrationTest


  ## Tests for show.
  test "should display analysis page that exists without being logged in" do 
    analysis = analyses(:one)

    get analysis_path(analysis.id)
    assert_template "analyses/show"
    assert_select ".name", analysis.name
    assert_select ".summary", analysis.summary
    assert_select ".description", analysis.description

    assert_select "a[href=?]", edit_analysis_path(analysis.id), count: 0
    assert_select "a[href=?][data-method=delete]", analysis_path(analysis.id), 
      count: 0
  end

  test "should display edit option on a analysis page when logged in" do
    log_in_as users(:foo)
    analysis = analyses(:one)

    get analysis_path(analysis.id)
    assert_template "analyses/show"
    assert_select ".name", analysis.name
    assert_select ".summary", analysis.summary
    assert_select ".description", analysis.description

    assert_select "a[href=?]", edit_analysis_path(analysis.id), count: 1
    assert_select "a[href=?][data-method=delete]", analysis_path(analysis.id), 
      count: 1
  end

  test "should display a 404 page if id isn't valid" do 
    response = get analysis_path(-1)
    assert response == 404
    assert_select "h1", "The page you were looking for doesn't exist."
  end


  ## Tests for index.
  test "should display all analysis entries" do 
    analyses = [analyses(:one), analyses(:two), analyses(:three)]

    get analyses_path
    assert_template "analyses/index"

    assert_select ".analysis.index-entry", count: analyses.size

    analyses.each do |analysis|
      assert_select "div", "data-analysis-id" => analysis.id do
        assert_select ".name", analysis.name
        assert_select ".summary", analysis.summary
      end
    end
  end


  ## Navigate from the home page to the analysis index, then visit a specific
  ## analysis page.
  test "should be able to navigate to analysis page from home page" do 
    analysis = analyses(:two)

    get root_url
    assert_select "a", href: analyses_path

    ## "Click" on the link.
    get analyses_path
    assert_template "analyses/index"
    assert_select "a", href: analysis_path(analysis.id)

    ## "Click" on the analysis page link.
    get analysis_path(analysis.id)
    assert_template "analyses/show"
  end


  ## Navigate from the home page to the analysis index, then visit a specific
  ## analysis page, edit it, and submit the changes.
  test "should be able to navigate to analysis page and edit from home page" do 
    log_in_as users(:foo)

    analysis = analyses(:two)

    get root_url
    assert_select "a", href: analyses_path

    ## "Click" on the link.
    get analyses_path
    assert_template "analyses/index"
    assert_select "a", href: analysis_path(analysis.id)

    ## "Click" on the analysis page link.
    get analysis_path(analysis.id)
    assert_template "analyses/show"
    assert_select "a[href=?]", edit_analysis_path(analysis.id), count: 1

    ## "Click" the edit button.
    get edit_analysis_path(analysis.id)
    assert_template "analyses/edit"

    ## Simulate submitting the changes.
    @request.env['CONTENT_TYPE'] = 'application/json'
    patch analysis_path(analysis.id)+'.json', params: {analysis: {
      name: "A VERY NEW NAME!"
    }}
    result = JSON.parse(@response.body)
    assert result['success']
    assert result['redirect'] == analysis_path(analysis.id)
    
    get result['redirect']
    assert_template "analyses/show"

    assert_select ".name", "A VERY NEW NAME!"
  end




  ## From the homepage, create a new analysis page and navigate to it from the
  ## analysis index.
  test "should be able to create a new analysis page, navigate to it, "+
      "and delete it" do
    log_in_as users(:foo)

    analysis_name = "MY ANALYSIS"
    analysis_description = "YABBA DABBA DOO"
    analysis_summary = "A ANALYSIS SUMMARY"

    get root_url
    assert_select "a", href: new_analysis_path

    ## "Click" on the link.
    get new_analysis_path
    assert_template "analyses/new"

    ## Simulate submitting the page info.
    @request.env['CONTENT_TYPE'] = 'application/json'
    post analyses_path+'.json', params: {analysis: {
      name: analysis_name, summary: analysis_summary, 
      description: analysis_description
    }}
    analysis = Analysis.last
    assert analysis.name == analysis_name
    assert analysis.summary == analysis_summary
    assert analysis.description == analysis_description
    result = JSON.parse(@response.body)
    assert result['success']
    get result['redirect']
    assert_template "analyses/show"
    assert_select ".name", analysis.name
    assert_select "a", href: analyses_path

    ## "Click" on the Analysis link.
    get analyses_path
    assert_template "analyses/index"
    assert_select "a", href: analysis_path(analysis.id)

    ## "Click" on the analysis page link.
    get analysis_path(analysis.id)
    assert_template "analyses/show"

    ## Delete the page.
    assert_select "a[href=?][data-method=delete]", analysis_path(analysis.id), 
      count: 1
    delete analysis_path(analysis.id)
    follow_redirect!
    assert_template 'analyses/index'

    ## "Click" on the Analysis link.
    get analyses_path
    assert_template "analyses/index"

    ## Confirm that the deleted analysis page is not there.
    assert_select "a[href=?]", analysis_path(analysis.id), count: 0

  end


end