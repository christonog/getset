class AddIataCityPermalink < ActiveRecord::Migration
  def self.up
    create_table :iatas do |t|
      t.string :iata_city
      t.string :iata_code
      t.string :iata_city_permalink
    end
  end

  def self.down
    drop_table :iatas
  end
end
