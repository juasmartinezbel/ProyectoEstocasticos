class WelcomesController < ApplicationController
  before_action :set_welcome, only: [:show, :edit, :update, :destroy]
  
  #Hash de los nodos
  #{id => {dilema, parent, sons, probability, gain, E}}
  Questions={}
  #Arreglo con TODOS los nodos
  Ids=[];
  #Arreglo para mapear los nodos
  IdsAv=[];

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

    #Agrandamos nuestra variable de ids general
    Ids.append(Ids.length)

    #Verificamos si no es el nodo origen
    if (Ids.length-1>0)

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
      else
         @gain = nil
         IdsAv.append(Ids.length-1)
      end
      
      #Convierto variables y anexo a que este nodo es hijo de su padre
      @parent=@parent.to_i
      Questions[@parent.to_i]["sons"].append(@id)


    #EN CASO DE QUE SÍ SEA EL NODO ORIGEN convierto sus valores a default
    else

      IdsAv.append(Ids.length-1)
      @parent=nil
      @probability=nil
    end


    #Renderizo el json que me permitirá actualizar la lista en tiempo real
    render json: {
        id: @id,
        content: @text,
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
      "E"=>0}
    puts Questions
  end
end
