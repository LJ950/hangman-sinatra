require 'sinatra/base'
#require 'sinatra/reloader'
# pull in the helpers and controllers
Dir.glob('./app/{models,helpers,controllers}/*.rb').each { |file| require file }

# map the controllers to routes
run ApplicationController
use HangmanController


run Sinatra::Application