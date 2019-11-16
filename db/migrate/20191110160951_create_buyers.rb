class CreateBuyers < ActiveRecord::Migration[5.2]
  def change
    create_table :buyers do |t|
      t.integer :user_id, null: false
      t.integer :item_id, null: false

      t.timestamps
    end
  end
end
