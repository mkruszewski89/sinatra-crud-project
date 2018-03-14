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

  post '/recipes' do
    recipe = Recipe.create(name: params[:recipe][:name], instructions: params[:recipe][:instructions].join("|"))
    ingredients = params[:ingredients].collect {|ingredient_hash| Ingredient.find_or_create_by(name: ingredient_hash[:name])}
    quantities = params[:ingredients].collect {|ingredient_hash| ingredient_hash[:quantity].to_i}
    i=0
    while i < ingredients.length do
      RecipeIngredient.create(recipe: recipe, ingredient: ingredients[i], quantity: quantities[i])
      i += 1
    end
    user = User.find(session[:user_id])
    user.recipes << recipe
    user.save
  end

end
