class User < ActiveRecord::Base
  has_secure_password

  def self.is_logged_in?(session)
    !!session[:user_id]
  end

end
