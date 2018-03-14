class UserController < Sinatra::Base

  configure do
    use Rack::Flash
    enable :sessions
    set :session_secret, "password_security"
    set :views, "app/views/user"
  end

  get "/" do
    erb :home
  end

  get "/registration" do
    erb :registration
  end

  get "/account" do
    if User.is_logged_in?(session)
      @user = User.find(session[:user_id])
      erb :account
    else
      redirect '/registration'
    end
  end

  get '/logout' do
    session.clear if User.is_logged_in?(session)
    redirect '/'
  end

  post "/signup" do
    user = User.find_by(email: params[:email])
    if user
      flash[:message] = "Email already in use"
      redirect "/registartion"
    elsif params[:email] == "" || params[:password] == ""
      flash[:message] = "Please enter an email and password"
      redirect "/registration"
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
      redirect "/registration"
    else
      flash[:message] = "Email and password combination not found"
      redirect "/registration"
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

  delete '/account' do
    User.find(session[:user_id]).destroy
    flash[:message] = "Your account has been deleted"
    redirect '/registration'
  end

end
