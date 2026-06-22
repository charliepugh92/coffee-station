class CreateBases < ActiveRecord::Migration[8.1]
  def change
    create_table :bases do |t|
      t.references :station, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :surcharge_cents
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :bases, [ :station_id, :position ]

    create_table :base_categories do |t|
      t.references :base, null: false, foreign_key: true
      t.references :customization_category, null: false, foreign_key: true
      t.timestamps
    end
    add_index :base_categories, [ :base_id, :customization_category_id ],
      unique: true, name: "idx_base_categories_unique"

    # Replace the unused base_option_id (FK -> customization_options) with a
    # reference to the new standalone bases table.
    remove_reference :orders, :base_option, foreign_key: { to_table: :customization_options }, index: true
    add_reference :orders, :base, null: true, foreign_key: true, index: true
  end
end
