class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :station, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.string :share_token, null: false
      t.datetime :opened_at
      t.datetime :closed_at
      t.timestamps
    end

    add_index :sessions, :share_token, unique: true
    # At most one open session per station (status 0 = open).
    add_index :sessions, :station_id, unique: true, where: "status = 0",
      name: "idx_one_open_session_per_station"
  end
end
