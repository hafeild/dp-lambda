# This migration comes from bootsy (originally 20120628124845)
# frozen_string_literal: true
class CreateBootsyImageGalleries < ActiveRecord::Migration[5.0]
  def change
    create_table :bootsy_image_galleries do |t|
      t.references :bootsy_resource, polymorphic: true
      t.timestamps
    end
  end
end
