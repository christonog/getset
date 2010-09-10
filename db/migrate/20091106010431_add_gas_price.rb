class AddGasPrice < ActiveRecord::Migration
  def self.up
    add_column :locations, :gas_price, :float
  end

  def self.down
    remove_column :locations, :gas_price
  end
end
