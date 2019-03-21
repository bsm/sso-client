class Bsm::Sso::Client::Strategies::Ticket < Bsm::Sso::Client::Strategies::Base
  include Bsm::Sso::Client::UrlHelpers

  def valid?
    params[:ticket].present?
  end

  def authenticate!
    u = user_class.sso_consume(params[:ticket], service_url)
    u.nil? ? fail!(:invalid) : success!(u)
  end

  Warden::Strategies.add :sso_ticket, self
end
