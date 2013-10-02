class UserRequest < ActiveRecord::Base
  
  def bump
    self.requests_done = requests_done + 1
    save
  end
  
end
