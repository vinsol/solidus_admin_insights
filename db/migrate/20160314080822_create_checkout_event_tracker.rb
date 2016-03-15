class CreateCheckoutEventTracker < ActiveRecord::Migration
  def change
    create_table :spree_checkout_events do |t|
      t.references :actor, polymorphic: true
      t.references :object, polymorphic: true
      t.string :activity
      t.string :referrer
      t.string :previous_state
      t.string :new_state
      t.string :session_id
      t.timestamps null: false
    end
  end
end
