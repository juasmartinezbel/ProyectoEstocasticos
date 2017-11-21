Rails.application.routes.draw do
  resources :nodes
  get '/results', to: "nodes#find_choice"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
