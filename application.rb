require 'sinatra'
require 'sinatra/flash'
require 'sinatra/reloader' if development?
require './database.rb'
require 'sass'

# Use SASS to generate CSS
get '/style.css' do 
    scss :style
end

# Enable Session, Set the Authorized User's Username and Password
configure do
    enable :sessions
    set :username, "Mouhu"
    set :password, "19951124"
end

# Use a Class Variable as the Global Variable to control the Login / Logout Button
@@status = "login"

get '/' do
    @title = "Home"
    erb :home
end

get '/about' do
    @title = "About Application"
    erb :about
end

get '/contact' do
    @title = "Contact Info"
    erb :contact
end

get '/video' do
    @title = "Sample Video"
    erb :video
end

get '/login' do
    @title = "Login"
    erb :login
end

post '/login' do
    # Check if it is the Athorized User
    if params[:username] == settings.username && params[:password] == settings.password
        session[:login] = true
        @@status = "logout"
        redirect '/'
    else
        flash[:error] = "Please Enter the Username and Password Correctly!"
        redirect '/login'
    end
end

get '/logout' do
    # Clear the Session and Logout
    session.clear
    @@status = "login"
    redirect '/'
end