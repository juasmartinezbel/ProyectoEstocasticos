class WelcomesController < ApplicationController
  before_action :set_welcome, only: [:show, :edit, :update, :destroy]
  Questions={}
  Ids=[];
  IdsAv=[];
  def index
    @IdsMap= IdsAv.map{|value| [ value, value ]}
    @m = Ids.length
    @number=Ids
  end

  def clear
    Questions.clear
    Ids.clear
    @IdsMap=Ids.map{|value| [ value, value ]}
    @m = Ids.length
    @number=Ids
    redirect_to action: "index"
  end

  def add
    @hash
    dilema=params[:hash]['text'].to_s
    @text= dilema
    @parent=params[:hash]['parent']
    @probability=params[:hash]['probability']
    @choice = params[:hash]['choice']
    @gain = params[:hash]['gain']
    @id = (Ids.length).to_i

    Ids.append(Ids.length)

    if (Ids.length-1>0)
      if(@choice.eql? "False")
        @text = @text + " | "+ @probability.to_s + "% | Parent: " + @parent.to_s
      else
        @text = @text + " | Parent: " + @parent.to_s
        @probability=100
      end

      unless(@gain.to_s.eql? "")
         @text = @text + " | Gain: " + @gain.to_s
         @gain =  @gain.to_f
      else
         @gain = nil
         IdsAv.append(Ids.length-1)
      end
      @parent=@parent.to_i

      Questions[@parent.to_i]["sons"].append(@id)
    else
      IdsAv.append(Ids.length-1)
      @parent=nil
      @probability=100
    end

    render json: {
        id: @id,
        content: @text,
        size: Ids.length
    }

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
