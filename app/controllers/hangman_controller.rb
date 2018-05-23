configure do
  enable :sessions
  set :session_secret, "secret"
end

@@bad_guesses = []
@@good_guesses = []
@@game_over = false

get '/hangman' do
	menu_option = params["menu_option"]
	game_over = @@game_over
	case menu_option
	when "Exit to Menu"
		session.clear
		redirect to ('/')
	when "New Game"
		session["game"] = Hangman.new
		session["game"].new_game
		redirect to ('/hangman-play')
	when "Load Game"
		redirect to ('/hangman-load')
	when "Save Game"
		redirect to ('/hangman-save')
	when "Continue Game"
		redirect to ('/hangman-play')
	end
	erb :hangman, :locals => {:game => session["game"], :game_over => game_over}
end

get '/hangman-play' do
	redirect to ('/hangman') if params["menu_option"] == "Main Menu"
	redirect to ('/hangman-save') if params["menu_option"] == "Save Game"

	response = session["game"].play(params["guess"])
	image = "/img1.jpg"
	image = load_image unless @@bad_guesses.empty?
	bad_guesses = @@bad_guesses
	guessed_word = @@good_guesses.join(" ")
	num_bad_guesses = @@bad_guesses.size

	erb :hangman_play, :locals => {:bad_guesses => bad_guesses, :guessed_word => guessed_word, :response => response, :num_bad_guesses => num_bad_guesses, :image => image}
end

get '/hangman-save' do
	unless session["user_name"] == nil
		saves = session["game"].display_saves(session["user_name"])
		response = "Saved Games:"
	else
		saves = nil
		response = nil
	end
	erb :hangman_saves, :locals => {:saves => saves, :response => response, :user => session["user_name"]}
end

post '/hangman-save' do
	redirect to ('/hangman-play') if params["menu_option"] == "Continue Game"
	redirect to ('/hangman') if params["menu_option"] == "Main Menu"
	redirect to ('/hangman-load') if params["menu_option"] == "Load Game"

	if params["save_name"] == "" || params["user_name"] == ""
		response = "Please enter a save name and a user name."
	else
		session["user_name"] = params["user_name"]
		response = session["game"].save_game(params["save_name"], session["user_name"], session["game"])
	end
	saves = session["game"].display_saves(session["user_name"])
	erb :hangman_saves, :locals => {:saves => saves, :response => response, :user => session["user_name"]}
end

get '/hangman-load' do
	redirect to ('/user') if session["user_name"].nil?
	if session["game"].nil?
		session["game"] = Hangman.new
	end
 	saves = session["game"].display_saves(session["user_name"])
 	response = "Saved Games:"
 	erb :hangman_load, :locals => {:saves => saves, :response => response, :user => session["user_name"]}
end

post '/hangman-load' do
	if params["menu_option"] == "Main Menu"
		redirect to ('/hangman')
	elsif params["menu_option"] == "Change User"
		redirect to ('/user')
	end

	session["game"] = load_game(session["user_name"], params["game_name"])
	redirect to ('/hangman-play')
end

get '/user' do
	response = "Please enter a user name."
	erb :users, :locals => {:response => response}
end

post '/user' do
	redirect to ('/hangman') if params["menu_option"] == "Main Menu"
	session["user_name"] = params["user_name"]
	if user_exists?(session["user_name"])
		redirect to ('/hangman-load')
	else
		response = "Sorry, that user name does not exist."
		session["user_name"] = nil
	end
	erb :users, :locals => {:response => response}
end

error do
  "Error! Have you got cookies enabled on your browser?"
end

private

def user_exists?(user_name)
	return false if Dir.glob('saves/*').empty?
	user_names = Dir.glob('saves/*').select {|f| File.directory? f}
	user_names.each do |folder|
		if folder == "saves/#{user_name}"
			return true
		else
			return false
		end
	end
end

def load_image
	img = @@bad_guesses.size
	case img
	when 1
		return "/img2.jpg"
	when 2
		return "/img3.jpg"
	when 3
		return "/img4.jpg"
	when 4
		return "/img5.jpg"
	when 5
		return "/img6.jpg"
	when 6
		return "/img7.jpg"
	else
		return "/img1.jpg"
	end
end