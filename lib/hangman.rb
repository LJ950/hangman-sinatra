require 'YAML'

class Hangman
	def initialize
		@word = []
		@bad_guesses = []
		@all_guesses = []
		@@bad_guesses = []
		@@good_guesses = []
		@@game_over = false
	end

	def play(guess=nil)
		return if guess == nil
		if guess.length < 1 || /^\d+$/.match(guess) #checks for guess and string (not integer)
			return "Guess a letter!"
		end
		@all_guesses.each do |letter|
			if letter == guess
				return "You've already tried \'#{guess.upcase}\'!"
			end
		end
		@bad_guesses << guess #adds guess to the bad_guesses array
		@all_guesses << guess
		letter_match(guess) if guess.length == 1 #checks for single letters
		@@bad_guesses = @bad_guesses
		check = end_game?(guess)
		if check #checks for full word guesses and if any remaining turns
			return check
		else
			return
		end
	end

	def new_game 
		initialize #resets all variables to start a game.
		pick_word
		@@good_guesses = Array.new(@word.length, "_") #creates an array of underscores to show how many letters are missing
	end

	def pick_word #opens dictionary text file and adds each word (line) between 5 and 12 letters to the dictionary array.
		dictionary = []
		File.open('lib/5desk.txt').readlines.each do |line|
			dictionary << line.downcase if line.strip.length.between?(5,12)
		end
		@word = dictionary.sample.strip.split("") #picks random element on dictionary array (word) and splits it into an array of letters.
	end

	def letter_match(guess) #iterates the word array and adds letters which match the guess to the guessed_word array leaving unmatched letters as underscores.
		@word.each_with_index do |letter, i|
			if guess == letter
				@bad_guesses.delete(guess) #removes correct guesses from the bad_guesses array
				@@good_guesses[i] = letter
			end
		end
	end

	def end_game?(word_guess=nil) #checks if word matches guesses and if whole word guesses match word.
		if @@good_guesses == @word || word_guess == @word.join
			@bad_guesses.delete(word_guess)
			@@good_guesses = @word
			@@game_over = true
			return "You win! You correctly guessed the word was #{@word.join}"
		elsif @bad_guesses.size == 6 #checks number of turns remaining
			@@game_over = true
			@@good_guesses = @word
			return "You lose! The word was #{@word.join}"
		else
			@@bad_guesses = @bad_guesses
			return false
		end
	end

	def display_saves(user_name) #lists files in 'saves' folder
		if Dir.exist?("saves/#{user_name}")
			saves = []
			Dir.entries("saves/#{user_name}").each do |f|
				saves << f unless f =~ /^\.\.?$/
			end
			return saves
		else
			return
		end
	end

	#serialization with YAML
	def save_game(save_name, user_name, game)
		Dir.mkdir("/saves") unless Dir.exists? "/saves"
		Dir.mkdir("saves/#{user_name}") unless Dir.exists? "saves/#{user_name}"

		display_saves(user_name).each do |save|
			if save_name == save
				return "File Exists! Choose another name."
			end
		end

		File.open("saves/#{user_name}/#{save_name}",'w') do |f|
			f.write game.to_yaml
		end
		return "save successful"	
	end

	def reload_variables
		@@game_over = false
		@@good_guesses = Array.new(@word.length, "_")
		@@bad_guesses = @bad_guesses
		@all_guesses.each do |guess| #creates good guesses list
			letter_match(guess)
		end
	end
end		

def load_game(user_name, save_name)
	loaded_game = YAML.load(File.open("saves/#{user_name}/#{save_name}",'r'))
	loaded_game.reload_variables
	loaded_game
end