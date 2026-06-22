# frozen_string_literal: true

class CreatePushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :push_subscriptions do |t|
      # subscriber is a User (host devices) or an Order (a guest's tracked order).
      t.references :subscriber, polymorphic: true, null: false, index: true
      t.string :endpoint, null: false
      t.string :p256dh_key, null: false
      t.string :auth_key, null: false

      t.timestamps
    end

    # One row per browser push registration; lets register act as an upsert.
    add_index :push_subscriptions, :endpoint, unique: true
  end
end
