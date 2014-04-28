class Bsm::Sso::Client::FailureApp < ActionController::Metal
  include ActionController::RackDelegation
  include ActionController::Redirecting
  include Bsm::Sso::Client::UrlHelpers

  def self.call(env)
    action(:respond).call(env)
  end

  def self.default_url_options(*args)
    ApplicationController.default_url_options(*args)
  end

  def respond
    if Bsm::Sso::Client.navigational_formats.include?(request.format.try(:to_sym)) || request.accepts.include?(Mime::HTML)
      request.xhr? ? respond_with_js! : redirect!
    else
      stop!
    end
  end

  def redirect!
    path = env["warden.options"].try(:[], :attempted_path) || request.fullpath
    redirect_to Bsm::Sso::Client.user_class.sso_sign_in_url(:service => service_url(path)), :status => 303
  end

  def respond_with_js!
    self.status = :ok
    self.content_type  = request.format.to_s
    self.response_body = "alert('Your session has expired');"
  end

  def stop!
    self.status = 403
    self.content_type  = Mime::HTML
    self.response_body = "<html><head></head><body><h1>Access Forbidden</h1></body></html>"
  end

end
