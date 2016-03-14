class CreateSpreePageEvents < ActiveRecord::Migration
  def change
    create_table :spree_page_events do |t|
      t.references :actor, polymorphic: true
      t.references :object, polymorphic: true
      t.string :activity
      t.string :referrer
      t.string :search_keywords
    end
  end
end
