class WelcomesController < ApplicationController
  before_action :set_welcome, only: [:show, :edit, :update, :destroy]

  #Hash de los nodos
  #{id => {dilema, parent, sons, probability, gain, E}}
  Questions={}
  #Arreglo con TODOS los nodos
  Ids=[];
  #Arreglo para mapear los nodos en el menu desplegable de "padre"
  IdsAv=[];
  #Variable que me chequea si faltan hojas
  NodesNoLeaves=[];
  #Variable que me almacena las hojas que llevo
  Leaves=[];




####################################################
####################################################
####################################################
  #Metodo Index básico
    #Me establece una hash para el menú del despliegue de seleccionar padre
    #Un número para mostrar cuantos nodos se llevan    
  def index
    @IdsMap= IdsAv.map{|value| [ value, value ]}
    @m = Ids.length
    @decisions = current_user.decisions
  end




####################################################
####################################################
####################################################
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
####################################################
####################################################
####################################################
  #Me verifica si en su estado actual, el arbol está completo
  def check
    @value
    if(NodesNoLeaves.empty? && Ids.length > 1)
      @value="El arbol está completo"
    else
      @value="Faltan hojas"
    end
    @value
  end

####################################################
####################################################
####################################################
  #Me añade un nodo
  def add

    #Iniciamos la variable hash para usarla en index.html.erb
    @hash



    #igualamos los valores del formulario en index.html.erb
    dilema=params[:hash]['text'].to_s
    @text= dilema
    @parent=params[:hash]['parent']
    @probability=params[:hash]['probability']
    @gain = params[:hash]['gain']
    @id = (Ids.length).to_i
    @E=0.0
    @route=[]

    #Agrandamos nuestra variable de ids general
    Ids.append(Ids.length)

    #Verificamos si no es el nodo origen
    if (@id>0)

      #En caso de ser el nodo origen, verificamos que
      #La opción sea una probabilidad aleatoria (El dolar sube, puedo perder, puedo ganar)
      #O es una opción de la que yo puedo escoger (Tomo la prueba 1, prueba 2, etc.)  
      unless(@probability.to_s.eql? "")
        @text = @text + " | "+ @probability.to_s + "% | Parent: " + @parent.to_s
      else
        @text = @text + " | Parent: " + @parent.to_s
        @probability=100
        @route=[@id]
      end


      #Este unless me verifica si el nodo recién creado tiene ganancias  
      unless(@gain.to_s.eql? "")
         @text = @text + " | Gain: " + @gain.to_s
         @gain =  @gain.to_f
         Leaves.push(@id)
         @E=@gain*(@probability.to_f/100)
      else
         @gain = -Float::INFINITY
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
      @gain = -Float::INFINITY
      @route=[0]
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
      "E"=>@E,
      "route"=>@route}


    print_all
  end

####################################################
####################################################
####################################################
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

####################################################
####################################################
####################################################
  #Me retorna la solución
  def find_choice
    #Chequeamos que efectivamente no falte nada
    @result=check

    unless (@result.to_s.eql? "Faltan hojas")
      
      #Clonamos el arbol para evitar malos cambios
      questions=Questions.clone

      #Hacemos el while general
      while true
        puts "\n"
        puts "\n"
        puts questions
        puts "\n"
        puts "\n"
        #Tomamos el primer elemento de la lista de hojas
        u=Leaves.shift

        #Comprobamos que no sea 0, si es así, habremos acabado
        if (u==0)
          break
        end

        #Tomamos los valores de interés
        node=questions[u]
        parent=node['parent']
        probability=node['probability']
        gain=node['gain']
        e=node['E']


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
        questions[parent]['E']=questions[parent]['probability']*questions[parent]['gain']
        
        #Comprobamos si el padre no tiene más hijos, para volverlo una hoja
        questions[parent]["sons"].delete(u)
        if(questions[parent]["sons"].empty?)
          Leaves.push(parent)
        end
      end


      #Me verifica la ruta
      @ideal_route=questions[0]['route']
      @so=""
      puts "The Ideal Route"
      puts @ideal_route.to_s

      if @ideal_route[1].kind_of?(Array)
        @so=questions[@ideal_route[1][0]]["dilema"]
      else
        @so=questions[@ideal_route[1]]["dilema"]
      end

      @dilema=questions[0]["dilema"]
      @ideal_route=@ideal_route.to_s
      @ideal_gain=questions[0]["gain"].to_s


      puts "\n####################################"
      puts "La mejor opción para "+@dilema+" será: "+@so 
      puts "\nLa ruta ideal es:"+@ideal_route
      puts "La ganancia total es: "+@ideal_gain
      puts "\n####################################"
    

    else

      puts "\n\n\n\nQUE NO ESTÁ COMPLETO CONCHE TU MADRE"
      redirect_to action: "index"


    end

  end




end
