class HangmanController < ApplicationController
	helpers HangmanHelpers

	get '/hangman' do
#		session.clear
		erb :hangman, :locals => {:game => session[:game], :game_over => @game_over}
	end

	get '/hangman-play' do
		if session[:game].nil?
			session[:game] = Hangman.new
		end
		@message = session[:game].play(params[:guess])
		@guessed_word = session[:game].good_guesses.join(" ")
		@bad_guesses = session[:game].bad_guesses
		@image = load_image
		erb :hangman_play#, :locals => {:bad_guesses => @bad_guesses, :guessed_word => guessed_word, :response => response, :num_bad_guesses => num_bad_guesses, :image => image}
	end

	get '/reset' do
		session[:game] = nil
		redirect to ('/hangman-play')
	end

	get '/hangman-save' do
		unless session[:user_name] == nil
			saves = session[:game].display_saves(session[:user_name])
			response = "Saved Games:"
		else
			saves = nil
			response = nil
		end
		erb :hangman_saves, :locals => {:saves => saves, :response => response, :user => session[:user_name]}
	end

	post '/hangman-save' do
		unless params[:user_name].nil?
			login_user
		end
		if params[:save_name] == "" || session[:user_name] == ""
			response = "Please enter a save name and a user name."
		else
			response = session[:game].save_game(params[:save_name], session[:user_name], session[:game])
		end
		saves = session[:game].display_saves(session[:user_name])
		erb :hangman_saves, :locals => {:saves => saves, :response => response, :user => session[:user_name]}
	end

	get '/hangman-load' do
		redirect to ('/user') if session[:user_name].nil?
		if session[:game].nil?
			session[:game] = Hangman.new
		end
	 	saves = session[:game].display_saves(session[:user_name])
	 	response = "Saved Games:"
	 	erb :hangman_load, :locals => {:saves => saves, :response => response, :user => session[:user_name]}
	end

	post '/hangman-load' do
		game = Hangman.new
		session[:game] = game.load_game(session[:user_name], params[:game_name])
		redirect to ('/hangman-play')
	end

	get '/user' do
		response = "Please enter a user name."
		erb :users, :locals => {:response => response}
	end

	post '/user' do
		login_user
		if user_exists?(session[:user_name])
			redirect to ('/hangman-load')
		else
			response = "Sorry, that user name does not exist."
			session[:user_name] = nil
		end
		erb :users, :locals => {:response => response}
	end

	error do
	  "Error! Have you got cookies enabled on your browser?"
	end

	private

	def login_user
		session[:user_name] = params[:user_name]
		@current_user = params[:user_name]
	end

#	def logout_user
#		session[:user_name] = nil
#		@current_user = nil
#	end

	def user_exists?(user_name)
		return false if Dir.glob("saves/*").empty?
		user_names = Dir.glob("saves/*").select {|f| File.directory? f}
		user_names.each do |folder|
			return true if folder == "saves/#{user_name}"
		end
		false
	end

	def load_image
		img = @bad_guesses.count unless @bad_guesses.nil?
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

end