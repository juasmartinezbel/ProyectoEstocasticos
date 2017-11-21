class NodesController < ApplicationController
  before_action :set_node, only: [:show, :update, :destroy]
  require 'json'

  # GET /nodes
  def index
    @nodes = Node.all

    render json: @nodes
  end

  # GET /nodes/1
  def show
    render json: @node
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
    @route = []

    if (@id>0)  
      puts @id
      parent=Node.find_by(:ide=>@parent_id)

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

  def show_tree
    @origin = Node.find_by(:ide=>0, :children => nil)
  end

  # PATCH/PUT /nodes/1
  def update
    if @node.update(node_params)
      render json: @node
    else
      render json: @node.errors, status: :unprocessable_entity
    end
  end

  # DELETE /nodes/1
  def destroy
    @node.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_node
      @node = Node.find(params[:id])
    end


end
