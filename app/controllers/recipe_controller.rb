class RecipeController < Sinatra::Base

  configure do
    use Rack::Flash
    enable :sessions
    set :session_secret, "password_security"
    set :views, "app/views/recipe"
  end

  get '/recipes' do
    if User.is_logged_in?(session)
      @recipes = Recipe.all.sort_by {|recipe| recipe.name}
      erb :index
    else
      flash[:message] = "You must be logged in to view recipes"
      redirect '../registration'
    end
  end

  get '/recipes/yourrecipes' do
    if User.is_logged_in?(session)
      user = User.find(session[:user_id])
      @recipes = user.recipes.sort_by {|recipe| recipe.name}
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
      @instructions = @recipe.instructions.split("|")
      erb :view
    else
      flash[:message] = "You must be logged in to view a recipe"
      redirect '../registration'
    end
  end

  get '/recipes/:id/edit' do
    @recipe = Recipe.find(params[:id])
    @instructions = @recipe.instructions.split("|")
    @user = User.find(session[:user_id])
    if @user && @user.id == @recipe.user.id
      erb :edit
    else
      flash[:message] = "You must be logged in and the owner of the recipe to edit the recipe"
      redirect '../registration'
    end
  end

  post '/recipes' do
    if params[:recipe] == "" || (!params[:recipe][:instructions] || params[:recipe][:instructions].empty?) || (!params[:ingredients] || params[:ingredients] == "")
      flash[:message] = "Recipes must have a name, ingredients, and instructions"
      redirect '/recipes/new'
    else
      user = User.find(session[:user_id])
      recipe = Recipe.create(name: params[:recipe][:name], instructions: params[:recipe][:instructions].collect{|instruction|instruction if instruction!=""}.compact.join("|"))
      ingredients = params[:ingredients].collect {|ingredient_hash| Ingredient.find_or_create_by(name: ingredient_hash[:name]) if ingredient_hash[:name] != "" && ingredient_hash[:quantity] != ""}.compact
      quantities = params[:ingredients].collect {|ingredient_hash| ingredient_hash[:quantity] if ingredient_hash[:name] != "" && ingredient_hash[:quantity] != ""}.compact
      i=0
      while i < ingredients.length do
        RecipeIngredient.create(recipe: recipe, ingredient: ingredients[i], quantity: quantities[i])
        i += 1
      end
      user.recipes << recipe
      user.save
      redirect "/recipes/#{recipe.id}"
    end
  end

  patch '/recipes/:id' do
    recipe = Recipe.find(params[:id])
    if params[:recipe] == "" || (!params[:recipe][:instructions] || params[:recipe][:instructions].empty?) || (!params[:ingredients] || params[:ingredients] == "")
      flash[:message] = "Recipes must have a name, ingredients, and instructions"
      redirect '/recipes/#{recipe.id}/edit'
    else
      recipe.update(name: params[:recipe][:name], instructions: params[:recipe][:instructions].collect{|instruction|instruction if instruction!=""}.compact.join("|"))
      ingredients = params[:ingredients].collect {|ingredient_hash| Ingredient.find_or_create_by(name: ingredient_hash[:name]) if ingredient_hash[:name] != "" && ingredient_hash[:quantity] != ""}.compact
      quantities = params[:ingredients].collect {|ingredient_hash| ingredient_hash[:quantity] if ingredient_hash[:name] != "" && ingredient_hash[:quantity] != ""}.compact
      recipe.recipe_ingredients.destroy_all
      i=0
      while i < ingredients.length do
        RecipeIngredient.create(recipe: recipe, ingredient: ingredients[i], quantity: quantities[i])
        i += 1
      end
      redirect "/recipes/#{recipe.id}"
    end
  end

end
