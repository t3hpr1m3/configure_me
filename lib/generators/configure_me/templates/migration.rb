class Create<%= class_name.pluralize %> < ActiveRecord::Migration
  def self.up
    create_table :<%= plural_name %> do |t|
      t.string  :key
      t.text    :value

      t.timestamps
    end

    add_index :<%= plural_name %>, :key,                :unique => true
  end

  def self.down
    drop_table :<%= plural_name %>
  end
end
