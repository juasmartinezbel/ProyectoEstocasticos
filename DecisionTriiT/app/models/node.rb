class Node < ApplicationRecord
	def self.is_complete
		g=self.has_all_leaves
		u=self.has_all_probabilities
		h=u&&g
		h
	end

	def self.has_all_leaves
		u=true
		g=Node.where("nodes.children = ? AND nodes.expected_value is ?", "", nil);
		if g.length>0
			u=false
		else
			u=true
		end
		u
	end

	def self.has_all_probabilities
		u=true
		g=Node.where("nodes.full_prob != ?", 100.0);
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
	def self.update_probabilities(ide_del)
		my_node=Node.find_by(:ide=>ide_del)
		my_parent=Node.find_by(:ide=>my_node.parent)
		
		if(my_parent.children.eql? "")
			my_parent.full_prob=0.0
			my_parent.save
		else
			if(my_node.probability!=100.0)
				my_parent.full_prob=my_parent.full_prob-my_node.probability
				my_parent.save
			end	
		end

		
	end

	def self.update_ids(ide_del)
		size=Node.all.size
		for id in (0...size) do
			u=Node.find_by(:ide=>id)
			if(id>ide_del)
				u.ide-=1
			end
			child=u.children.split(',').map { |s| s.to_i }
			new_child=[]
			for j in child do
				if (j>ide_del)
					new_child.append(j-1)
				else
					new_child.append(j)
				end
			end

			new_child_text=Node.turn(new_child)
			u.children=new_child_text
			if(u.parent>ide_del)
				u.parent-=1
			end
			u.save
		end
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

		puts my_node
		for i in my_node["children"]
			u.append(turn_tree(tree, i.to_i))
		end

		my_tree = {
			  "_id"=>node,
			  "name"=>my_node["name"].to_s,
			  "parent"=>my_node["parent"].to_s,
			  "probability"=>(my_node["probability"].to_f*100).to_s+'%',
			  "gain"=>my_node["gain"].to_s,
			  "expected_value"=>my_node["expected_value"].to_s,
			  "size"=>1,
			  "route"=>my_node["route"],
			  "children"=>u
		}
		my_tree
	end

	def self.turn(ar)
		txt=''
		for i in ar
			txt=i.to_s+','
		end
		txt
	end
end
