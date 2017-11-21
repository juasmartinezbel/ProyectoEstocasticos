# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.last
dec = Decision.create(question: "Who am I?")
user.decisions << dec

root_node = Node.create(info: "root", gain: 100, probability: 0.8)
dec.node = root_node

root_node.children.create(info: "child", gain: 50, probability: 0.4)

=begin
[{
    "id":1,
    "info":"root",
    "probability":"0.8",
    "gain":"100.0",
    "ancestry":null,
    "decision_id":1,
    "children":[
        {
            "id":2,
            "info":"child",
            "probability":"0.4",
            "gain":"50.0",
            "ancestry":"1",
            "decision_id":null,
            "children":[
            ]
                
        }
    ]
    
}]
=end

