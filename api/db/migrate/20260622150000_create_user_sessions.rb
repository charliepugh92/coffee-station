# frozen_string_literal: true

# Replaces the single-`jti`-per-user JWT revocation (devise-jwt JTIMatcher) with a
# per-device allowlist. Each dispatched token gets its own row, so a host can stay
# signed in on multiple devices and revoke them independently.
class CreateUserSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :user_sessions do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :jti, null: false
      t.datetime :exp, null: false
      t.string :user_agent
      t.string :device_label
      t.datetime :last_active_at

      t.timestamps
    end

    add_index :user_sessions, :jti, unique: true

    # The old strategy stored one shared jti on the user row; the allowlist makes it obsolete.
    remove_index :users, :jti
    remove_column :users, :jti, :string
  end
end
