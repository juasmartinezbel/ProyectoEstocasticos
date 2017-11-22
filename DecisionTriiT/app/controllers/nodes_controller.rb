class NodesController < ApplicationController
  before_action :set_node, only: [:update, :destroy]
  require 'json'

  # GET /nodes
  def index
    size=Node.all.size

    if size>0
      tree=Node.generate_tree
      puts tree
      puts "\n\n\n\n"
      puts Node.is_complete
      @tree_node=Node.json_tree(tree).to_json
      render json: @tree_node
    else
      render json: {:message=>"There is no nodes"}
    end

  end
  def can_be_deleted
    @nodes=Node.where("children = ?", "").pluck(:ide)
    render json: {:nodes=>@nodes}
  end

  def get_size
    @size=Node.all.size
    render json: {:size=>@size}
  end

  def clear
    
    Node.delete_all
    render json: {:Success=>"All nodes have been deleted"}
  end

  def check_if_null(par)
    nu=par
    if (par.to_s.eql? "null")
      nu=nil
    end
    nu
  end

  def set_prob(parent, probability)
    if(probability==100)
      puts probability
      if (parent.full_prob!=100.to_f&&parent.full_prob!=0.to_f)
        return false
      end
      parent.full_prob=100
    else
      prob=parent.full_prob + probability
      if(prob>100)
        return false
      else
        parent.full_prob+=probability
      end
    end

    parent.save
    return true
  end

  # POST /nodes
  def create
    dilema=params[:name].to_s
    @text= dilema
    @parent_id=params[:parent]
    check_if_null(@parent_id)
    @probability=params[:probability]
    check_if_null(@probability)
    @gain = params[:gain]
    check_if_null(@gain)
    @id = Node.all.size
    @E=nil
    @route = ""
    is_leaf=false

    if (@id>0)  

      #Me comprueba que el nodo sí sea el que debe ser
      parent=Node.find_by(:ide=>@parent_id)

      if parent.gain>-Float::INFINITY
        render json: {:Error=>"This node can't have children"}, status: :unprocessable_entity and return
      end


      #En caso de ser el nodo origen, verificamos que
      #La opción sea una probabilidad aleatoria (El dolar sube, puedo perder, puedo ganar)
      #O es una opción de la que yo puedo escoger (Tomo la prueba 1, prueba 2, etc.)  
      unless(@probability.to_s.eql? "")
        @probability=@probability.to_f
        g=set_prob(parent, @probability)
        unless(g)
          render json: {:Error=>"This node can't have that children"}, status: :unprocessable_entity and return
        end
      else
        @text = @text + " | Parent: " + @parent_id.to_s
        @probability=100
        g=set_prob(parent, @probability)
        unless(g)
          render json: {:Error=>"This node can't have that children"}, status: :unprocessable_entity and return
        end
        @route=@id.to_s
      end


      #Este unless me verifica si el nodo recién creado tiene ganancias  
      unless(@gain.to_s.eql? "")
         @text = @text + " | Gain: " + @gain.to_s
         @gain =  @gain.to_f
         @E=@gain*(@probability.to_f/100)
         is_leaf=true

      else
         @gain = -Float::INFINITY
      end
      
      #Convierto variables y anexo a que este nodo es hijo de su padre
      parent.children+=@id.to_s+","
      parent.save

    #EN CASO DE QUE SÍ SEA EL NODO ORIGEN convierto sus valores a default
    else
      @parent_id=-1
      @probability=nil
      @gain = -Float::INFINITY
      @route=0
    end

    @node=Node.new
    @node.ide=@id
    @node.name=dilema
    @node.parent=@parent_id
    @node.probability=@probability
    @node.children=""
    unless(is_leaf)
      @node.full_prob= 0.0
    else
      @node.full_prob= 100.0
    end
    @node.expected_value=@E
    @node.gain=@gain 
    @node.route=@route

    @node.save
    
    

    if @node.save
      tree=Node.generate_tree
      puts tree
      puts "\n\n\n\n"
      puts Node.is_complete
      @tree_node=Node.json_tree(tree).to_json
      render json: @tree_node, status: :created
    else
      render json: @node.errors, status: :unprocessable_entity
    end

  end


  # PATCH/PUT /nodes/1
  def update


    if(params[:parent]!=@node.parent && @node.ide!=0)
      puts "TATATATATTAAADASDASDAS"
      @new_parent=Node.find_by(:ide=>params[:parent])
      @parent=Node.find_by(:ide=>@node.parent)

      g=set_prob(parent, @probability)
      unless(g)
        render json: {:Error=>"This node can't update to that porcentage"}, status: :unprocessable_entity and return
      end

      arr=@parent.children.split(',').map { |s| s.to_i }
      arr.delete(@node.ide)
      ar=Node.turn(arr)
      @parent.children=ar
      @parent.save
      Node.update_probabilities(@node.ide)


      @new_parent.children+=@node.ide.to_s
      @new_parent.save
    end

    if(params[:parent]==@node.parent )
      unless(params[:probability].nil?)
        my_parent=Node.find_by(:ide=>@node.parent)
        child=my_parent.children.split(',').map { |s| s.to_i }
        if(child.size>1)
          my_parent.full_prob=0.0
          my_parent.save
        else
          if(params[:probability].to_f !=100.0)
            my_parent.full_prob=my_parent.full_prob-@node.probability.to_f
            my_parent.save
          end
        end

        g=set_prob(my_parent, params[:probability].to_f)
        unless(g)
          render json: {:Error=>"This node can't handle that percentage anymore"}, status: :unprocessable_entity and return
        end

      end
    end


    if @node.update(node_params)
      tree=Node.generate_tree
      puts tree
      puts "\n\n\n\n"
      puts Node.is_complete
      @tree_node=Node.json_tree(tree).to_json

      render json: @tree_node
    else
      render json: @node.errors, status: :unprocessable_entity
    end
  end

  # DELETE /nodes/1
  def destroy

    if(@node.ide==0||@node.children !="")
      render json: {:Error=>"This node can't be deleted"}, status: :unprocessable_entity and return
    end

    @parent=Node.find_by(:ide=>@node.parent)
    arr=@parent.children.split(',').map { |s| s.to_i }
    
    arr.delete(@node.ide)
    ar=Node.turn(arr)
    @parent.children=ar
    @parent.save
    Node.update_probabilities(@node.ide)
    if (@node.ide+1!=Node.all.size)
      Node.update_ids(@node.ide)
    end
    @node.destroy
    


    tree=Node.generate_tree
    puts tree
    puts "\n\n\n\n"
    puts Node.is_complete
    @tree_node=Node.json_tree(tree).to_json
    render json: @tree_node

  end


####################################################
####################################################
####################################################
  #Me retorna la solución
  def find_choice
    #Chequeamos que efectivamente no falte nada
    @result=Node.is_complete
    overall=Node.generate_tree
    puts "aaaaaaaaaaa"
    if (@result)
      leaves=Node.get_leaves  
      #Clonamos el arbol para evitar malos cambios
      questions=overall.clone

      #Hacemos el while general
      while true
        #Tomamos el primer elemento de la lista de hojas
        u=leaves.shift

        #Comprobamos que no sea 0, si es así, habremos acabado
        if (u==0)
          break
        end

        #Tomamos los valores de interés
        node=questions[u]
        parent=node['parent']
        probability=node['probability']
        gain=node['gain']
        e=node['expected_value']


        #Si la probabilidad es de 1, es una opción arbitraria
        #Por lo que harémos la función de seleccionar el de beneficio mayor
        if(probability==1.0)
          if(gain>questions[parent]['gain'])
            questions[parent]['gain']=gain
            questions[parent]["route"]=[parent]+node["route"]
          end
        else
        #Si es de probabilidad aleatoria, sumamos los E (Prob*Gain) de los hijos
          if(questions[parent]['gain']==-Float::INFINITY)
            questions[parent]['gain']=0
          end

          questions[parent]['gain']+=e    
          #Asignamos las rutas posibles
          unless(node["route"].empty?)
            questions[parent]["route"]=questions[parent]["route"]+[node["route"]]
          end
        end


        #Calculamos el E del padre
        questions[parent]['expected_value']=questions[parent]['probability']*questions[parent]['gain']
        
        #Comprobamos si el padre no tiene más hijos, para volverlo una hoja
        questions[parent]["children"].delete(u)
        if(questions[parent]["children"].empty?)
          leaves.push(parent)
        end
      end


      #Me verifica la ruta
      @ideal_route=questions[0]['route']
      @so=""
      puts "The Ideal Route"
      puts @ideal_route.to_s
      if(@ideal_route.length!=1)
        if @ideal_route[1].kind_of?(Array)
          @so=questions[@ideal_route[1][0]]["name"]
        else
          @so=questions[@ideal_route[1]]["name"]
        end
      else
        @so = "La opción es aleatoria, así que no depende del usuario"
      end
      @dilema=questions[0]["name"]
      @ideal_route=@ideal_route.to_s
      @ideal_gain=questions[0]["gain"].to_s


      puts "\n####################################"
      puts "La mejor opción para "+@dilema+" será: "+@so 
      puts "\nLa ruta ideal es:"+@ideal_route
      puts "La ganancia total es: "+@ideal_gain
      puts "\n####################################"

      @results = {
        "Dilema"=>@dilema,
        "Option"=>@so,
        "Route"=>@ideal_route,
        "Gain"=>@ideal_gain
      }

      render json: @results.to_json

    else

      render json: {:Error=>"The tree is not complete"}, status: :unprocessable_entity and return

    end

  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_node
      @node = Node.find_by(:ide=>params[:id])
      if(@node.nil?)
        render json: {:Error=>"This node doesn't exist. You sure you put the id of the Node and not the one from the database?"}, status: :unprocessable_entity and return
      end
    end

    def node_params
      params.require(:node).permit(:name, :parent, :gain, :probability)
    end

end
