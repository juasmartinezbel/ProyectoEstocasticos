class CreateNodes < ActiveRecord::Migration[5.1]
  def change
    create_table :nodes do |t|
      t.string :info
      t.decimal :probability, default: 0.0
      t.decimal :gain, default: 0.0
    end
  end
end
