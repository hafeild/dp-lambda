require 'test_helper'

class SoftwareTest < ActiveSupport::TestCase
  test "valid with a creator, a unique name, a summary and a description" do 
    software = Software.new(
      creator: users(:foo),
      name: "A very unique name",
      summary: "a summary",
      description: "a description"
    )

    assert software.save, "Couldn't save"
  end

  test "must have a creator" do 
    software = Software.new(
      name: "A very unique name",
      summary: "a summary",
      description: "a description"
    )

    assert_not software.save, "Saved without error, but should not have"
  end

  test "must have a name" do
    software = Software.new(
      creator: users(:foo),
      summary: "a summary",
      description: "a description"
    )

    assert_not software.save, "Saved without error, but should not have"
  end

  test "must have a summary" do 
    software = Software.new(
      creator: users(:foo),
      name: "A very unique name",
      description: "a description"
    )

    assert_not software.save, "Saved without error, but should not have"
  end

  test "must have a description" do 
    software = Software.new(
      creator: users(:foo),
      name: "A very unique name",
      summary: "a summary",
    )

    assert_not software.save, "Saved without error, but should not have" 
  end

  test "name must be unique" do
    software = Software.new(
      creator: users(:foo),
      name: software(:one).name,
      summary: "a summary",
      description: "a description"
    )

    assert_not software.save, "Saved without error, but should not have"
  end

end
