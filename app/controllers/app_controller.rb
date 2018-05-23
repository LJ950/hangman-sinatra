get '/' do
	menu_option = params["menu_option"]
	case menu_option
	when "Hangman"
	#	load 'hangman_controller.rb'
		redirect to ('/hangman')
	end
	erb :index
end