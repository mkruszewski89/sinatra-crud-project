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

  get '/recipes/favorites' do
    if User.is_logged_in?(session)
      user = User.find(session[:user_id])
      erb :favorites
    else
      flash[:message] = "You must be logged in to view favorite recipes"
      redirect '../registration'
    end
  end

  get '/recipes/yourrecipes' do
    if User.is_logged_in?(session)
      user = User.find(session[:user_id])
      @recipes = user.recipes
      erb :yourrecipes
    else
      flash[:message] = "You must be logged in to view your recipes"
      redirect '../registration'
    end
  end

  get '/recipes/new' do
    if User.is_logged_in?(session)
      @recipes = Recipe.all
      erb :new
    else
      flash[:message] = "You must be logged in to create a recipe"
      redirect '../registration'
    end
  end

  get '/recipes/:id' do
    if User.is_logged_in?(session)
      @user = User.find(session[:user_id])
      @recipe = Recipe.find(params[:id])
      erb :view
    else
      flash[:message] = "You must be logged in to view a recipe"
      redirect '../registration'
    end
  end

  post '/recipes' do
    user = User.find(session[:user_id])
    recipe = Recipe.create(name: params[:recipe][:name], instructions: params[:recipe][:instructions].join("|"))
    ingredients = params[:ingredients].collect {|ingredient_hash| Ingredient.find_or_create_by(name: ingredient_hash[:name])}
    quantities = params[:ingredients].collect {|ingredient_hash| ingredient_hash[:quantity]}
    i=0
    while i < ingredients.length do
      RecipeIngredient.create(recipe: recipe, ingredient: ingredients[i], quantity: quantities[i])
      i += 1
    end
    user.recipes << recipe
    user.save
  end

end
