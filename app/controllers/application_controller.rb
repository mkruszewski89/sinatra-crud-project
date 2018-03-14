class ApplicationController < Sinatra::Base

  configure do
    use Rack::Flash
    enable :sessions
    set :session_secret, "password_security"
    set :views, "app/views"
  end

  get "/" do
    erb :home
  end

  get "/account" do
    if User.is_logged_in?(session)
      @user = User.find(session[:user_id])
      erb :account
    else
      redirect '/'
    end
  end

  get '/logout' do
    if User.is_logged_in?(session)
      session.clear
      redirect '/'
    else
      redirect '/'
    end
  end

  post "/signup" do
    user = User.find_by(email: params[:email])
    if user
      flash[:message] = "Email already in use"
      redirect "/"
    elsif params[:email] == "" || params[:password] == ""
      flash[:message] = "Please enter an email and password"
      redirect "/"
    else
      user = User.create(params)
      session[:user_id] = user.id
      redirect "/account"
    end
  end

  post "/login" do
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/account"
    elsif params[:email] == "" || params[:password] == ""
      flash[:message] = "Please enter an email and password"
      redirect "/"
    else
      flash[:message] = "Email and password combination not found"
      redirect "/"
    end
  end

  patch '/account' do
    user = User.find(session[:user_id])
    user.update(email: params[:email]) if params[:email] != ""
    user.update(password: params[:password]) if params[:password] != ""
    if params[:email] == "" && params[:password] == ""
      flash[:message] = "No edits were made"
    else
      flash[:message] = "Your account has been updated"
    end
    redirect '/account'
  end

end
