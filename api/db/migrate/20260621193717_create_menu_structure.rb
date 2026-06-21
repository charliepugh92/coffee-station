class CreateMenuStructure < ActiveRecord::Migration[8.1]
  def change
    create_table :stations do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug
      t.text :description
      t.timestamps
    end
    add_index :stations, [ :user_id, :slug ], unique: true, where: "slug IS NOT NULL"

    create_table :customization_categories do |t|
      t.references :station, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :selection_mode, null: false, default: 0
      t.boolean :required, null: false, default: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :customization_categories, [ :station_id, :position ]

    create_table :customization_options do |t|
      t.references :customization_category, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :surcharge_cents
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :customization_options, [ :customization_category_id, :position ]

    create_table :menu_presets do |t|
      t.references :station, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :menu_presets, [ :station_id, :position ]

    create_table :menu_preset_options do |t|
      t.references :menu_preset, null: false, foreign_key: true
      t.references :customization_option, null: false, foreign_key: true
      t.timestamps
    end
    add_index :menu_preset_options, [ :menu_preset_id, :customization_option_id ],
      unique: true, name: "idx_preset_options_unique"
  end
end
