require './config/environment'

use Rack::MethodOverride
use RecipeController
run UserController
