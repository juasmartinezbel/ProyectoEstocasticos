class Node < ApplicationRecord
    has_ancestry
    belongs_to :decision, optional: true
end
