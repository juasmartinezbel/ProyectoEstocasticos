Rails.application.routes.draw do
  resources :nodes
  root :to=> "nodes#index"
  get '/results', to: "nodes#find_choice"
  get '/clear', to: "nodes#clear"
  get '/size', to: "nodes#get_size"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
