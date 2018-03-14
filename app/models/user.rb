class User < ActiveRecord::Base
  has_secure_password
  has_many :recipes

  def self.is_logged_in?(session)
    !!session[:user_id]
  end

end
