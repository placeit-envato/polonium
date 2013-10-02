class SiteController < ApplicationController

  before_filter :authenticate_user!, :only => :dashboard

  def index
    redirect_to dashboard_path if current_user
  end
  
  def dashbboard
  end
  
  def about
  end
  
  def register
  end
  
  def sign_in
  end
  
end