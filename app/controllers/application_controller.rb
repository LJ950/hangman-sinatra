class ApplicationController < Sinatra::Base
#	helpers ApplicationHelpers

#  configure :development do
#    register Sinatra::Reloader
#  end

  configure do
	  enable :sessions
	  set :session_secret, "secret"
	end
# configure sinatra
	set :root, Dir['./app']
	set :public_folder, Proc.new { File.join(root, 'public') }
	set :erb, :layout => :'layouts/application'
	set :views, File.expand_path('../../views', __FILE__)

	get '/' do
		session.clear
		erb :index
	end

end