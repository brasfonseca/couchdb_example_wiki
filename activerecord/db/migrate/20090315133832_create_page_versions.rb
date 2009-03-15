class CreatePageVersions < ActiveRecord::Migration
  def self.up
    add_column :pages, :version, :integer, :default => 1
    Page.create_versioned_table do |t|
      t.column :version, :integer
      t.column :page_id, :integer
      t.column :body, :text
    end
  end

  def self.down
    remove_column :pages, :version
    drop_table :page_versions
  end
end
