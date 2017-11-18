Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root :to=> "welcomes#index"
  post '/a', to: "welcomes#clear" 
  get '/a', to: "welcomes#clear" 
  post '/', to: 'welcomes#add'
end
