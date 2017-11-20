class Node < ApplicationRecord
	def self.is_complete
		u=true
		g=Node.where("nodes.children = ? AND nodes.expected_value is ?", "", nil);
		if g.length>0
			u=false
		else
			u=true
		end
		u
	end

	def self.get_leaves
		Node.where("nodes.expected_value is not null").pluck(:ide)
	end

	def self.generate_tree
		puts "\nArbol:"
		@Tree={}
		size=Node.all.size

		puts size
		for id in (0...size)
			u=Node.find_by(:ide=>id)
			ev=-213
			if(u.expected_value.nil?)
				ev=0.0
			else
				ev=u.expected_value
			end

			@Tree[id] = {
			  "name"=>u.name,
			  "parent"=>u.parent.to_i,
			  "probability"=>u.probability.to_f/100,
			  "gain"=>u.gain,
			  "children"=>u.children.split(',').map { |s| s.to_i },
			  "expected_value"=>ev,
			  "route"=>u.route.split(',').map { |s| s.to_i }
			}
			print id.to_s+"=> "
			puts @Tree[id]

			@Tree
		end
		
	end
end
