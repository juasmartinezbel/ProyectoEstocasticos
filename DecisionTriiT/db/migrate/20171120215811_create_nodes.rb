class CreateNodes < ActiveRecord::Migration[5.1]
  def change
    create_table :nodes do |t|
      t.integer :ide
      t.string :name
      t.integer :parent
      t.float :gain
      t.float :probability
      t.float :expected_value
      t.string :route
      t.string :children
      t.float :full_prob
      t.timestamps
    end
  end
end
