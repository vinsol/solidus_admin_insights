class AddQueryStringToPageEvents < ActiveRecord::Migration
  def change
    add_column :spree_page_events, :query_string, :string
  end
end
