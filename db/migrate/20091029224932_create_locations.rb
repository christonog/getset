class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :city_to
      t.string :city_from

      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
