Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root :to=> "welcomes#index"
  
  post '/a', to: "welcomes#clear" 
  get '/a', to: "welcomes#clear"

  post '/c', to: "welcomes#find_choice" 
  get '/c', to: "welcomes#find_choice"

  post '/', to: 'welcomes#add'

end
