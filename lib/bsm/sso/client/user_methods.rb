module Bsm::Sso::Client::UserMethods
  extend ActiveSupport::Concern

  included do
    class << self
      delegate :sso_sign_in_url, :sso_sign_out_url, to: :"Bsm::Sso::Client::User"
    end
  end

  module ClassMethods
    def sso_find(id)
      resource = Bsm::Sso::Client::User.sso_find(id)
      sso_cache(resource, :find) if resource
    end

    def sso_consume(*args)
      resource = Bsm::Sso::Client::User.sso_consume(*args)
      sso_cache(resource, :consume) if resource
    end

    def sso_authenticate(*args)
      resource = Bsm::Sso::Client::User.sso_authenticate(*args)
      sso_cache(resource, :authenticate) if resource
    end

    def sso_authorize(*args)
      resource = Bsm::Sso::Client::User.sso_authorize(*args)
      sso_cache(resource, :authorize) if resource
    end

    def sso_cache(resource, _action=nil)
      new(resource.attributes)
    end
  end
end
