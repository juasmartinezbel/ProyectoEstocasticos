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
			  "children"=>u.children.split(',').map { |s| s.to_i },
			  "probability"=>u.probability.to_f/100,
			  "gain"=>u.gain,
			  "expected_value"=>ev,
			  "route"=>u.route.split(',').map { |s| s.to_i }
			  

			}
			print id.to_s+"=> "
			puts @Tree[id]
		end
		@Tree
		
	end

	def self.json_tree(tree)
		@json_tree=Node.turn_tree(tree, 0)
		@json_tree
	end	

	def self.turn_tree(tree, node)
		my_node=tree[node]
		u=[]


		for i in my_node["children"]
			u.append(turn_tree(tree, i.to_i))
		end

		my_tree = {
			  "name"=>my_node["name"].to_s,
			  "parent"=>my_node["parent"].to_s,
			  "probability"=>my_node["probability"].to_s,
			  "gain"=>my_node["gain"].to_s,
			  "expected_value"=>my_node["expected_value"].to_s,
			  "route"=>my_node["route"],
			  "children"=>u
		}
		my_tree
	end
end
