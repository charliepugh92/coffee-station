class AddOrderMemoryAndDropSelections < ActiveRecord::Migration[8.1]
  def up
    # Orders carry a self-contained snapshot of what was ordered, so the host can
    # freely edit/delete menu config without breaking past orders.
    add_column :orders, :memory, :jsonb, null: false, default: {}

    # The live join to options is gone — `memory` is the single source of truth.
    drop_table :order_selections

    # Deleting a base/preset should leave the order intact (memory keeps the name).
    remove_foreign_key :orders, column: :base_id
    add_foreign_key :orders, :bases, column: :base_id, on_delete: :nullify
    remove_foreign_key :orders, :menu_presets
    add_foreign_key :orders, :menu_presets, on_delete: :nullify
  end

  def down
    remove_foreign_key :orders, column: :base_id
    add_foreign_key :orders, :bases, column: :base_id
    remove_foreign_key :orders, :menu_presets
    add_foreign_key :orders, :menu_presets

    create_table :order_selections do |t|
      t.bigint :customization_option_id, null: false
      t.bigint :order_id, null: false
      t.timestamps
      t.index [ :customization_option_id ], name: "index_order_selections_on_customization_option_id"
      t.index [ :order_id, :customization_option_id ], name: "idx_order_selections_unique", unique: true
      t.index [ :order_id ], name: "index_order_selections_on_order_id"
    end
    add_foreign_key :order_selections, :customization_options
    add_foreign_key :order_selections, :orders

    remove_column :orders, :memory
  end
end
