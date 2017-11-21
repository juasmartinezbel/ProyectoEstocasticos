class AddDecisionToNode < ActiveRecord::Migration[5.1]
  def change
    add_reference :nodes, :decision, index: true, foreign_key: true
  end
end
