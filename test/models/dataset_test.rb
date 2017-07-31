require 'test_helper'

class DatasetTest < ActiveSupport::TestCase
  test "valid with a creator, a unique name, a summary and a description" do 
    dataset = Dataset.new(
      creator: users(:foo),
      name: "A very unique name",
      summary: "a summary",
      description: "a description"
    )

    assert dataset.save, "Couldn't save"
  end

  test "must have a creator" do 
    dataset = Dataset.new(
      name: "A very unique name",
      summary: "a summary",
      description: "a description"
    )

    assert_not dataset.save, "Saved without error, but should not have"
  end

  test "must have a name" do
    dataset = Dataset.new(
      creator: users(:foo),
      summary: "a summary",
      description: "a description"
    )

    assert_not dataset.save, "Saved without error, but should not have"
  end

  test "must have a summary" do 
    dataset = Dataset.new(
      creator: users(:foo),
      name: "A very unique name",
      description: "a description"
    )

    assert_not dataset.save, "Saved without error, but should not have"
  end

  test "must have a description" do 
    dataset = Dataset.new(
      creator: users(:foo),
      name: "A very unique name",
      summary: "a summary",
    )

    assert_not dataset.save, "Saved without error, but should not have" 
  end

  test "name must be unique" do
    dataset = Dataset.new(
      creator: users(:foo),
      name: datasets(:one).name,
      summary: "a summary",
      description: "a description"
    )

    assert_not dataset.save, "Saved without error, but should not have"
  end

end
