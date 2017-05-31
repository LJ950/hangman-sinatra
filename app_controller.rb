require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'hangman_controller.rb'

set :views, Proc.new { File.join(root, "views") }

get '/' do
	load 'app_controller.rb'
	menu_option = params["menu_option"]
	case menu_option
	when "Hangman"
		load 'hangman_controller.rb'
		redirect to ('/hangman')
	end
	erb :index
end