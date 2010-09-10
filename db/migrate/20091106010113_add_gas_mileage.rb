class AddGasMileage < ActiveRecord::Migration
  def self.up
    add_column :locations, :gas_mileage, :float
  end

  def self.down
    remove_column :locations, :gas_mileage
  end
end
