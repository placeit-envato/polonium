class ProxyController < ApplicationController
  before_filter :validate_polonium_access, :only => [:get_request_token, :authorize]
  before_filter :validate_requests_available, :only => [:get_request_token, :authorize]
  before_filter :validate_params_for, :only => [:get_request_token, :authorize]
  before_filter :create_consumer, :only => [:get_request_token, :authorize, :callback]
  before_filter :create_client, :only => [:authorize, :callback]

  skip_before_filter :seo_redirect
  skip_before_filter :get_requested_site

  DEV_CALLBACK_URL = "http://poauth.local:{port}/callback"
  CALLBACK_URL     = Rails.env.EQL?('production') ? "http://poauth.com/callback" : nil

  def get_request_token
    request_token = @consumer.get_request_token(:oauth_callback => callback_url)

    render :json => {
      :oauth_consumer_key => @consumer.key,
      :oauth_consumer_secret => @consumer.secret,
      :oauth_token => request_token.token,
      :oauth_token_secret => request_token.secret,
      :oauth_version => params[:oauth_version],
      :oauth_api_config => {
        :site => @consumer.site,
        :request_token_path => @consumer.request_token_path,
        :access_token_path => @consumer.access_token_path,
        :authorize_path => @consumer.authorize_path
      }
    }, :callback => params[:callback]
  end

  def authorize
    if params[:oauth_version] == '1.0'
      request_token = OAuth::RequestToken.from_hash(@consumer, params)
      redirect_to request_token.authorize_url(:oauth_callback => callback_url)
    end
    if params[:oauth_version] == '2.0'
      redirect_to @client.auth_code.authorize_url(:redirect_uri => callback_url)
    end
  end

  def callback
    version = params[:code].present? ? '2.0' : '1.0'
    jsoned_params = params.merge(:oauth_version => version).to_json
    render :inline => "<script type=\"text/javascript\">window.opener.postMessage('#{jsoned_params}', '*')</script>"
  end
  
  def bad_request
    render :json => {:error => "Bad Request", :code => "400"}, :callback => params[:callback]
  end

  def not_authorized_api_call
    render :json => {:error => "Unauthorized", :code => "401"}, :callback => params[:callback]
  end
  
  def not_enough_requests
    render :json => {:error => "Not Enough Requests", :code => "401"}, :callback => params[:callback], :status => :unauthorized
  end

  private
  
  def callback_url
    @callback_url ||= CALLBACK_URL || DEV_CALLBACK_URL.gsub("{port}", request.port.to_s)
  end

  def create_consumer
    return unless params[:oauth_version] == '1.0'
    @consumer = OAuth::Consumer.new(params[:oauth_consumer_key], params[:oauth_consumer_secret],
      :site => params[:oauth_api_config][:site],
      :request_token_path => params[:oauth_api_config][:request_token_path],
      :access_token_path => params[:oauth_api_config][:access_token_path],
      :authorize_path => params[:oauth_api_config][:authorize_path]
    )
  end

  def create_client
    return unless params[:oauth_version] == '2.0'
    @client = OAuth2::Client.new(params[:oauth_consumer_key], params[:oauth_consumer_secret],
      :site => params[:oauth_api_config][:site],
      :authorize_url => params[:oauth_api_config][:authorize_path],
      :token_url => params[:oauth_api_config][:access_token_path]
    )
  end
  
  
  def validate_params_for
    valid = params[:oauth_version].present? && params[:oauth_consumer_key].present? &&
      params[:oauth_consumer_secret].present? && params[:oauth_api_config].present? &&
      params[:oauth_api_config][:site].present? && params[:oauth_api_config][:authorize_path].present? &&
      params[:oauth_api_config][:access_token_path].present?
    
    case params[:oauth_version]
      when '1.0'
        valid = valid && params[:oauth_api_config].present? && params[:oauth_api_config][:request_token_path].present?
      when '2.0'
        # still valid if valid lol!
      else
        valid = false
    end
    
    redirect_to bad_request_url(:callback => params[:callback]) unless valid
    true
  end
  
  def validate_polonium_access
    valid = params[:polonium_email].present? && params[:polonium_key].present? 
    
    if valid
      u = User.where(:email => params[:polonium_email]).first
      valid = u.polonium_key.eql?(params[:polonium_key])
    end
    
    redirect_to not_authorized_api_call_url(:callback => params[:callback]) unless valid
    true
  end
  
  def validate_requests_available
    # Skip validation if already validated!
    return true if params[:action] == 'authorize' && params[:oauth_version] == '1.0'
    
    user = User.where(:email => params[:polonium_email]).first
    
    redirect_to not_enough_requests_url(:callback => params[:callback]) unless user.has_requests_available?
    
    user.new_request
    true
  end
  
end

