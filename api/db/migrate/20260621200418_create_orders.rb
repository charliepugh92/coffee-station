class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :session, null: false, foreign_key: true
      t.string :guest_name, null: false
      t.string :guest_token, null: false
      t.references :base_option, null: true, foreign_key: { to_table: :customization_options }
      t.references :menu_preset, null: true, foreign_key: true
      t.integer :status, null: false, default: 0
      t.text :notes
      t.timestamps
    end
    add_index :orders, :guest_token, unique: true
    add_index :orders, [ :session_id, :status ]

    create_table :order_selections do |t|
      t.references :order, null: false, foreign_key: true
      t.references :customization_option, null: false, foreign_key: true
      t.timestamps
    end
    add_index :order_selections, [ :order_id, :customization_option_id ],
      unique: true, name: "idx_order_selections_unique"
  end
end
