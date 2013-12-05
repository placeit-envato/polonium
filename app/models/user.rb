require 'digest/sha1'
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  before_save :generate_key_salt

  def has_requests_available?
    return true #if premium
    
    time = Time.now.beginning_of_day
    requests = UserRequest.where(:user_id => id, :date => time).first
    
    return true unless requests.present?
    
    (5 - requests.requests_done) > 0
  end
  
  def polonium_key
    Digest::SHA1.hexdigest(email + key_salt)
  end
  
  def new_request
    time = Time.now.beginning_of_day
    request = UserRequest.where(:user_id => id, :date => time).first
    
    request = UserRequest.create(:user_id => id, :date => time, :requests_done => 0) unless request.present?
    
    request.bump
  end
  
  private
  
  def generate_key_salt
    self.key_salt = Digest::SHA1.hexdigest((Time.now.to_i % rand).to_s) unless key_salt.present?
  end
  
end
