class Bsm::Sso::Client::Strategies::HttpAuth < Bsm::Sso::Client::Strategies::Base

  def store?
    false
  end

  def valid?
    token.present?
  end

  def authenticate!
    u = user_class.sso_authorize(token)
    u.nil? ? fail!(:invalid) : success!(u)
  end

  def token
    return nil unless request.authorization && request.authorization =~ /^Basic (.*)/m

    @token ||= Base64.decode64(Regexp.last_match(1)).split(/:/, 2).first
  end

  Warden::Strategies.add :sso_http_auth, self
end
