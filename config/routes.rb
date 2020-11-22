# frozen_string_literal: true

SimpleRackFramework.application.define_routes do
  get '/tests', 'tests#index'
  get '/tests/:id', 'tests#show'
  post '/tests/create', 'tests#create'
  post '/tests/:id/update', 'tests#update'
  post '/tests/:id/delete', 'tests#destroy'
end
