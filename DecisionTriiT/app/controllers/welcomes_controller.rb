class WelcomesController < ApplicationController
  before_action :set_welcome, only: [:show, :edit, :update, :destroy]
  helper_method :print_all

  #Hash de los nodos
  #{id => {dilema, parent, sons, probability, gain, E}}
  Questions={}
  #Arreglo con TODOS los nodos
  Ids=[];
  #Arreglo para mapear los nodos
  IdsAv=[];
  #Variable que me chequea si faltan hojas
  NodesNoLeaves=[];
  #Variable que me almacena las hojas que llevo
  Leaves=[];

  #Metodo Index básico
    #Me establece una hash para el menú del despliegue de seleccionar padre
    #Un número para mostrar cuantos nodos se llevan    
  def index
    @IdsMap= IdsAv.map{|value| [ value, value ]}
    @m = Ids.length
  end

  #Método Clear
    #Me reinicia todos los valores y me regresa al index original
  def clear
    Questions.clear
    Ids.clear
    IdsAv.clear
    @IdsMap=Ids.map{|value| [ value, value ]}
    @m = Ids.length
    redirect_to action: "index"
  end


  #Me verifica si en su estado actual, el arbol está completo
  def check
    @value
    if(NodesNoLeaves.empty?)
      @value="El arbol está completo"
    else
      @value="Faltan hojas"
    end
    @value
  end


  #Me añade un nodo
  def add

    #Iniciamos la variable hash para usarla en index.html.erb
    @hash

    #igualamos los valores del formulario en index.html.erb
    dilema=params[:hash]['text'].to_s
    @text= dilema
    @parent=params[:hash]['parent']
    @probability=params[:hash]['probability']
    @choice = params[:hash]['choice']
    @gain = params[:hash]['gain']
    @id = (Ids.length).to_i
    @E=0.0


    #Agrandamos nuestra variable de ids general
    Ids.append(Ids.length)

    #Verificamos si no es el nodo origen
    if (@id>0)

      #En caso de ser el nodo origen, verificamos que
      #La opción sea una probabilidad aleatoria (El dolar sube, puedo perder, puedo ganar)
      #O es una opción de la que yo puedo escoger (Tomo la prueba 1, prueba 2, etc.)  
      if(@choice.eql? "False")
        @text = @text + " | "+ @probability.to_s + "% | Parent: " + @parent.to_s
      else
        @text = @text + " | Parent: " + @parent.to_s
        @probability=100
      end


      #Este unless me verifica si el nodo recién creado tiene ganancias  
      unless(@gain.to_s.eql? "")
         @text = @text + " | Gain: " + @gain.to_s
         @gain =  @gain.to_f
         Leaves.append(@id)
         @E=@gain*(@probability.to_f/100)
      else
         @gain = nil
         IdsAv.append(@id)
         NodesNoLeaves.append(@id)
      end
      
      

      #Convierto variables y anexo a que este nodo es hijo de su padre
      @parent=@parent.to_i
      if(Questions[@parent]["sons"].empty?)
        NodesNoLeaves.delete(@parent)
      end

      Questions[@parent]["sons"].append(@id)
      

    #EN CASO DE QUE SÍ SEA EL NODO ORIGEN convierto sus valores a default
    else

      IdsAv.append(@id)
      @parent=-1
      @probability=nil
      NodesNoLeaves.append(@id)
    end

    @message=check
    #Renderizo el json que me permitirá actualizar la lista en tiempo real
    render json: {
        id: @id,
        content: @text,
        message: @message,
        size: Ids.length
    }

    #Finalmente, anexo los valores a la hash
    newIt=Ids.length-1
    Questions[newIt] = {
      "dilema"=>dilema,
      "parent"=>@parent.to_i, 
      "probability"=>@probability.to_f/100,
      "gain"=>@gain,
      "sons"=>[],
      "E"=>@E}

    print_all
  end


  #Me imprime en consola para verificar si la información es correcta
  def print_all
    puts "\nArbol:"
    Ids.each do |f|
      print "\n"
      print f.to_s + "=>"
      puts Questions[f] 
    end
    print"\nEstos Nodos Necesitan Hijos: "
    puts NodesNoLeaves.to_s

    print"\nEstos Son Los Nodos Hojas: "
    puts Leaves.to_s
  end




end
