class Decision < ApplicationRecord
    has_one :node
    belongs_to :user
    
    def self.convert_decision_into_hash(decision_id)
       dec = self.find(decision_id)
       root_node = dec.node
       root_node.subtree.arrange_serializable.to_json
    end
end
