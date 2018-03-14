require './config/environment'

use Rack::MethodOverride
run UserController
