class CreateFeedback < ActiveRecord::Migration[8.1]
  def change
    create_table :ratings do |t|
      t.references :order, null: false, foreign_key: true, index: { unique: true }
      t.integer :stars, null: false
      t.timestamps
    end

    create_table :comments do |t|
      t.references :order, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end
  end
end
