require 'test_helper'
require 'erb'
class DatasetRenderTest < ActionDispatch::IntegrationTest


  ## Tests for show.
  test "should display dataset page that exists without being logged in" do 
    dataset = datasets(:one)

    get dataset_path(dataset.id)
    assert_template "datasets/show"
    assert_select ".name", dataset.name
    assert_select ".summary", dataset.summary
    assert_select "iframe.description[data-html=?]", 
      ERB::Util.url_encode(dataset.description)

    assert_select "a[href=?]", edit_dataset_path(dataset.id), count: 0
    assert_select "a[href=?][data-method=delete]", dataset_path(dataset.id), 
      count: 0
  end

  test "should display edit option on a dataset page when logged in" do
    log_in_as users(:foo)
    dataset = datasets(:one)

    get dataset_path(dataset.id)
    assert_template "datasets/show"
    assert_select ".name", dataset.name
    assert_select ".summary", dataset.summary
    assert_select "iframe.description[data-html=?]", 
      ERB::Util.url_encode(dataset.description)

    assert_select "a[href=?]", edit_dataset_path(dataset.id), count: 1
    assert_select "a[href=?][data-method=delete]", dataset_path(dataset.id), 
      count: 1
  end

  test "should display a 404 page if id isn't valid" do 
    response = get dataset_path(-1)
    assert response == 404
    assert_select "h1", "The page you were looking for doesn't exist."
  end


  ## Tests for index.
  test "should display all dataset entries" do 
    datasets = [datasets(:one), datasets(:two)]

    get datasets_path
    assert_template "datasets/index"

    assert_select ".dataset.index-entry", count: datasets.size

    datasets.each do |dataset|
      assert_select "div", "data-dataset-id" => dataset.id do
        assert_select ".name", dataset.name
        assert_select ".summary", dataset.summary
      end
    end
  end


  ## Navigate from the home page to the dataset index, then visit a specific
  ## dataset page.
  test "should be able to navigate to dataset page from home page" do 
    dataset = datasets(:two)

    get root_url
    assert_select "a", href: datasets_path

    ## "Click" on the link.
    get datasets_path
    assert_template "datasets/index"
    assert_select "a", href: dataset_path(dataset.id)

    ## "Click" on the dataset page link.
    get dataset_path(dataset.id)
    assert_template "datasets/show"
  end


  ## Navigate from the home page to the dataset index, then visit a specific
  ## dataset page, edit it, and submit the changes.
  test "should be able to navigate to dataset page and edit from home page" do 
    log_in_as users(:foo)

    dataset = datasets(:two)

    get root_url
    assert_select "a", href: datasets_path

    ## "Click" on the link.
    get datasets_path
    assert_template "datasets/index"
    assert_select "a", href: dataset_path(dataset.id)

    ## "Click" on the dataset page link.
    get dataset_path(dataset.id)
    assert_template "datasets/show"
    assert_select "a[href=?]", edit_dataset_path(dataset.id), count: 1

    ## "Click" the edit button.
    get edit_dataset_path(dataset.id)
    assert_template "datasets/edit"

    ## Simulate submitting the changes.
    @request.env['CONTENT_TYPE'] = 'application/json'
    patch dataset_path(dataset.id)+'.json', params: {dataset: {
      name: "A VERY NEW NAME!"
    }}
    result = JSON.parse(@response.body)
    assert result['success']
    assert result['redirect'] == dataset_path(dataset.id)
    
    get result['redirect']
    assert_template "datasets/show"

    assert_select ".name", "A VERY NEW NAME!"
  end




  ## From the homepage, create a new dataset page and navigate to it from the
  ## dataset index.
  test "should be able to create a new dataset page, navigate to it, "+
      "and delete it" do
    log_in_as users(:foo)

    dataset_name = "MY DATASET"
    dataset_description = "YABBA DABBA DOO"
    dataset_summary = "A DATASET SUMMARY"

    get root_url
    assert_select "a", href: new_dataset_path

    ## "Click" on the link.
    get new_dataset_path
    assert_template "datasets/new"

    ## Simulate submitting the page info.
    @request.env['CONTENT_TYPE'] = 'application/json'
    post datasets_path+'.json', params: {dataset: {
      name: dataset_name, summary: dataset_summary, 
      description: dataset_description
    }}
    dataset = Dataset.last
    assert dataset.name == dataset_name
    assert dataset.summary == dataset_summary
    assert dataset.description == dataset_description
    result = JSON.parse(@response.body)
    assert result['success']
    get result['redirect']
    assert_template "datasets/show"
    assert_select ".name", dataset.name
    assert_select "a", href: datasets_path

    ## "Click" on the Dataset link.
    get datasets_path
    assert_template "datasets/index"
    assert_select "a", href: dataset_path(dataset.id)

    ## "Click" on the dataset page link.
    get dataset_path(dataset.id)
    assert_template "datasets/show"

    ## Delete the page.
    assert_select "a[href=?][data-method=delete]", dataset_path(dataset.id), 
      count: 1
    delete dataset_path(dataset.id)
    follow_redirect!
    assert_template 'datasets/index'

    ## "Click" on the Dataset link.
    get datasets_path
    assert_template "datasets/index"

    ## Confirm that the deleted dataset page is not there.
    assert_select "a[href=?]", dataset_path(dataset.id), count: 0

  end


end