class AddFeedEntriesToLocation < ActiveRecord::Migration
  def self.up
    add_column :locations, :name, :string
    add_column :locations, :summary, :text
    add_column :locations, :url, :string
    add_column :locations, :published_at, :datetime
    add_column :locations, :guid, :string
  end

  def self.down
    remove_column :locations, :guid
    remove_column :locations, :published_at
    remove_column :locations, :url
    remove_column :locations, :summary
    remove_column :locations, :name
  end
end
