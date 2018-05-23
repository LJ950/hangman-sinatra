require 'sinatra'

get '/' do
  erb :index
end

# configure sinatra
set :root, Dir['./app']
set :public_folder, Proc.new { File.join(root, 'public') }
set :erb, :layout => :'layouts/application'