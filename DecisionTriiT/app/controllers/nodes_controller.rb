class NodesController < ApplicationController
  before_action :set_node, only: [:update, :destroy]
  require 'json'

  # GET /nodes
  def index
    
    tree=Node.generate_tree
    puts tree
    puts "\n\n\n\n"
    puts Node.is_complete
    @tree_node=Node.json_tree(tree).to_json
    render json: @tree_node

  end

  # POST /nodes
  def create
    dilema=params[:name].to_s
    @text= dilema
    @parent_id=params[:parent]
    @probability=params[:probability]
    @gain = params[:gain]
    @id = Node.all.size
    @E=nil
    @route = ""


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
        @text = @text + " | "+ @probability.to_s + "% | Parent: " + @parent_id.to_s
      else
        @text = @text + " | Parent: " + @parent_id.to_s
        @probability=100
        @route=@id.to_s
      end


      #Este unless me verifica si el nodo recién creado tiene ganancias  
      unless(@gain.to_s.eql? "")
         @text = @text + " | Gain: " + @gain.to_s
         @gain =  @gain.to_f
         @E=@gain*(@probability.to_f/100)
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
    if(params[:parent]!=@node.parent)
      @parent=Node.find_by(:ide=>@node.parent)
      arr=@parent.children.split(',').map { |s| s.to_i }
      arr.delete(@node.ide)
      ar=Node.turn(arr)
      @parent.children=ar
      @parent.save

      @new_parent=Node.find_by(:ide=>params[:parent])
      @new_parent.children+=@node.ide.to_s
      @new_parent.save
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
    @parent=Node.find_by(:ide=>@node.parent)
    arr=@parent.children.split(',').map { |s| s.to_i }
    
    arr.delete(@node.ide)
    ar=Node.turn(arr)
    @parent.children=ar
    @parent.save
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

      if @ideal_route[1].kind_of?(Array)
        @so=questions[@ideal_route[1][0]]["name"]
      else
        @so=questions[@ideal_route[1]]["name"]
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
    end

    def node_params
      params.require(:node).permit(:name, :parent, :gain, :probability)
    end

end
