require 'sinatra'
require 'sinatra/reloader'# if development?

configure do
  enable :sessions
  set :session_secret, "secret"
end

@@bad_guesses = []
@@guessed_word = []

class Hangman
	def initialize
		@guesses = []
		@turn = 0
		@word = []
		@@bad_guesses = []
		@@guessed_word = []
	end

	def menu(option)
		
#		puts "Please choose an option...
#		1. Continue current game
#		2. Save current game
#		3. Play a new game
#		4. Load a game
#		5. Exit"

		case option
		when 'Continue Game'
			if @turn == 0
				#puts "You're not currently playing a game!"
				menu
			else
			play
			end
		when 'New Game'
			new_game
		when 'Save Game'
			if @turn == 0
				#puts "You haven't started a game!"
				menu
			else
			save_game
			end
		when 'Load Game'
			load_game
		when 'Exit'
			#puts "Thanks for playing. Bye!"
			#exit
		end
	end

	def play(guess)
		return if guess == nil
		if guess.length < 1 || /^\d+$/.match(guess) #checks for guess and string (not integer)
			return "Guess a letter!"
		end
		@guesses << guess #adds guess to the guesses array
		letter_match(guess) if guess.length == 1 #checks for single letters
		@@bad_guesses = @guesses
		return end_game?(guess) #checks for full word guesses and if any remaining turns
	end

	def new_game 
		initialize #resets all variables to start a game.
		pick_word
		@@guessed_word = Array.new(@word.length, "_") #creates an array of underscores to show how many letters are missing
	end

	def pick_word #opens dictionary text file and adds each word (line) between 5 and 12 letters to the dictionary array.
		dictionary = []
		File.open('lib/5desk.txt').readlines.each do |line|
			dictionary << line.downcase if line.strip.length.between?(5,12)
		end
		@word = ["o","n","e"]#dictionary.sample.strip.split("") #picks random element on dictionary array (word) and splits it into an array of letters.
	end

	def letter_match(guess) #iterates the word array and adds letters which match the guess to the guessed_word array leaving unmatched letters as underscores.
		@word.each_with_index do |letter, i|
			if guess == letter
				@guesses.delete(guess) #removes correct guesses from the guesses array
				@@guessed_word[i] = letter
			end
		end
	end

	def end_game?(word_guess=nil) #checks if word matches guesses and if whole word guesses match word.
		if @@guessed_word == @word || word_guess == @word.join
			@guesses.delete(word_guess)
			@@guessed_word = @word
			return "You win! You correctly guessed the word was #{@word.join}"
		elsif @guesses.size == 4 #checks number of turns remaining
			return "You lose! The word was #{@word.join}"
		else
			@@bad_guesses = @guesses
			return
		end

	end

	def display_saves #lists files in 'saves' folder
		saves = []
		Dir.entries("saves").each do |f|
			saves << f unless f =~ /^\.\.?$/
		end
		return saves
	end

	#serialization with Marshal
	def save_game(save_name)
		Dir.mkdir("saves") unless Dir.exists? "saves"
		display_saves.each do |save|
			if save_name == save
				return "File Exists! Choose another name."
			end
		end
		File.open("saves/#{save_name}",'w') do |f|
			Marshal.dump(self, f)
		end
		return "save successful"
	end

	def load_game
		display_saves
		puts "Enter game name"
		name = gets.chomp
		File.open("saves/#{name}",'r') do |f|
			@loaded_game = Marshal.load(f)
		end
		@loaded_game.play
	end
end

get '/' do
	menu_option = params["menu_option"]
	
	case menu_option
	when "New Game"
		session["game"] = Hangman.new
		session["game"].new_game
		redirect to ('/play')
	when "Load Game"
		redirect to ('/save')
	when "Continue Game"
		redirect to ('/play')
	end
	erb :index
end

get '/play' do
	redirect to ('/') if params["menu_option"] == "Main Menu"
	redirect to ('/save') if params["menu_option"] == "Save Game"

	response = session["game"].play(params["guess"])
	bad_guesses = @@bad_guesses.join(", ")
	guessed_word = @@guessed_word.join(" ")

	erb :game, :locals => {:bad_guesses => bad_guesses, :guessed_word => guessed_word, :response => response}
end

get '/save' do
	saves = session["game"].display_saves
	response = nil
	erb :saves, :locals => {:saves => saves, :response => response}
end

post '/save' do
	redirect to ('/play') if params["menu_option"] == "Continue Game"
	redirect to ('/') if params["menu_option"] == "Main Menu"

	if params["save_name"] == ""
		response = "Please enter a save name."
	elsif params["save_name"] != nil
		response = session["game"].save_game(params["save_name"])
	end
	saves = session["game"].display_saves
	erb :saves, :locals => {:saves => saves, :response => response}
end