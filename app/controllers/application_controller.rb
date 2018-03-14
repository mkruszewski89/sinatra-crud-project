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
      session[:id] = user.id
      redirect "/account"
    end
  end

  post "/login" do
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session[:id] = user.id
      redirect "/account"
    elsif params[:email] == "" || params[:password] == ""
      flash[:message] = "Please enter an email and password"
      redirect "/"
    else
      flash[:message] = "Email and password combination not found"
      redirect "/"
    end
  end

  def current_user
    !!session[:user_id]
  end

  def logged_in?
    User.find(session[:user_id])
  end
end
