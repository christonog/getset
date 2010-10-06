class AddAmtrakCodesToIatas < ActiveRecord::Migration
  def self.up
    add_column :iatas, :amtrak_code, :string
  end

  def self.down
    remove_column :iatas, :amtrak_code
  end
end
