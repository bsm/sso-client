require 'rails'
require 'active_support/message_verifier'
require 'active_support/core_ext/object/acts_like'
require 'active_support/core_ext/time/acts_like'
require 'active_support/core_ext/date_time/acts_like'
require 'active_support/core_ext/numeric/time'
require 'active_support/dependencies'
require 'action_controller'
require 'action_controller/metal/exceptions'
require 'rails_warden'

module Bsm
  module Sso
    module Client
      UnauthorizedAccess = Class.new(ActionController::ActionControllerError)

      autoload :AbstractResource, 'bsm/sso/client/abstract_resource'
      autoload :User, 'bsm/sso/client/user'
      autoload :UserMethods, 'bsm/sso/client/user_methods'
      autoload :UrlHelpers, 'bsm/sso/client/url_helpers'
      autoload :FailureApp, 'bsm/sso/client/failure_app'
      autoload :Cached, 'bsm/sso/client/cached'
      autoload :Ability, 'bsm/sso/client/ability'
      autoload :AuthorizedController, 'bsm/sso/client/authorized_controller'

      mattr_accessor :secret
      @@secret = nil

      mattr_accessor :token_timeout
      @@token_timeout = 60.seconds

      mattr_accessor :expire_after
      @@expire_after = 2.hours

      mattr_writer :user_class
      @@user_class = nil

      mattr_accessor :warden_configuration
      @@warden_configuration = nil

      mattr_reader :navigational_formats
      @@navigational_formats = [:html, :all, :js, nil].to_set

      mattr_reader :api_formats
      @@api_formats = %i[xml json].to_set

      mattr_accessor :cache_store
      @@cache_store = ActiveSupport::Cache::NullStore.new namespace: "bsm:sso:client:#{Rails.env}"

      class << self

        delegate :site=, :site, to: :"Bsm::Sso::Client::AbstractResource"

        def user_class
          if @@user_class.respond_to?(:constantize)
            @@user_class.constantize
          else
            @@user_class || Bsm::Sso::Client::User
          end
        end

        # Default message verifier
        def verifier
          raise "Please configure a secret! Example: Bsm::Sso::Client.secret = '...'" unless secret.present?

          @verifier ||= ActiveSupport::MessageVerifier.new(secret)
        end

        # Configure the SSO. Example:
        #
        #   # config/initializers/sso.rb
        #   Bsm::Sso::Client.configure do |c|
        #     c.site = "https://sso.test.host"
        #     c.secret = "m4GHRWxvXiL3ZSR8adShpqNWXmepkqeyUqRfpB8F"
        #   end
        def configure(&block)
          tap(&block)
        end

        # Warden configuration. Example:
        #
        #   # config/initializers/sso.rb
        #   Bsm::Sso::Client.configure do |c|
        #     c.warden do |manager|
        #       manager.default_strategies << :my_strategy
        #     end
        #   end
        def warden(&block)
          @@warden_configuration = block
        end

        # Raises an UnauthorizedAccess exception
        def forbidden!(request, message=nil)
          message ||= "You are not permitted to access the resource in #{request.path}"
          raise UnauthorizedAccess, message
        end

      end
    end
  end
end

require 'bsm/sso/client/railtie'
require 'bsm/sso/client/warden_ext'
require 'bsm/sso/client/strategies'
