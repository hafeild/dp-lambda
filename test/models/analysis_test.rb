require 'test_helper'

class AnalysisTest < ActiveSupport::TestCase
  test "valid with a creator, a unique name, a summary and a description" do 
    analysis = Analysis.new(
      creator: users(:foo),
      name: "A very unique name",
      summary: "a summary",
      description: "a description"
    )

    assert analysis.save, "Couldn't save"
  end

  test "must have a creator" do 
    analysis = Analysis.new(
      name: "A very unique name",
      summary: "a summary",
      description: "a description"
    )

    assert_not analysis.save, "Saved without error, but should not have"
  end

  test "must have a name" do
    analysis = Analysis.new(
      creator: users(:foo),
      summary: "a summary",
      description: "a description"
    )

    assert_not analysis.save, "Saved without error, but should not have"
  end

  test "must have a summary" do 
    analysis = Analysis.new(
      creator: users(:foo),
      name: "A very unique name",
      description: "a description"
    )

    assert_not analysis.save, "Saved without error, but should not have"
  end

  test "must have a description" do 
    analysis = Analysis.new(
      creator: users(:foo),
      name: "A very unique name",
      summary: "a summary",
    )

    assert_not analysis.save, "Saved without error, but should not have" 
  end

  test "name must be unique" do
    analysis = Analysis.new(
      creator: users(:foo),
      name: analyses(:one).name,
      summary: "a summary",
      description: "a description"
    )

    assert_not analysis.save, "Saved without error, but should not have"
  end

end
