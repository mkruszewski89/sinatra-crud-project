class RecipeController < Sinatra::Base

  configure do
    use Rack::Flash
    enable :sessions
    set :session_secret, "password_security"
    set :views, "app/views/recipe"
  end

  get '/recipes' do
    if User.is_logged_in?(session)
      @recipes = Recipe.all
      erb :index
    else
      flash[:message] = "You must be logged in to view recipes"
      redirect '../registration'
    end
  end

  get '/recipes/new' do
    if User.is_logged_in?(session)
      @ingredients = Ingredient.all.sort_by {|ingredient| ingredient.name}
      erb :new
    else
      flash[:message] = "You must be logged in to create a recipe"
      redirect '../registration'
    end
  end

end
