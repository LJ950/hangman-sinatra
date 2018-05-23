require 'sinatra'

get '/' do
  "Hello World!"
end

# configure sinatra
set :root, Dir['./app']
set :public_folder, Proc.new { File.join(root, 'public') }
set :erb, :layout => :'layouts/application'