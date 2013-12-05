class SecureProxyController < ApplicationController

	def callback
	    version = params[:code].present? ? '2.0' : '1.0'
	    jsoned_params = params.merge(:oauth_version => version).to_json
	    render :inline => "<script type=\"text/javascript\">window.opener.postMessage('#{jsoned_params}', '*')</script>"
  	end

end