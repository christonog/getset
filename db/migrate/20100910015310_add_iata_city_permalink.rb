class AddIataCityPermalink < ActiveRecord::Migration
  def self.up
    add_column :iatas, :iata_city_permalink, :string
  end

  def self.down
    remove_column :iatas, :iata_city_permalink
  end
end
