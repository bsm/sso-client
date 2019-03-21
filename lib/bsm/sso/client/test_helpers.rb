module Bsm
  module Sso
    module Client
      module TestHelpers
        extend ActiveSupport::Concern

        included do
          before do
            @request.env['action_controller.instance'] = @controller
            @request.env['warden'] = warden
          end

          let :warden do
            Warden::Proxy.new @request.env, Warden::Manager.new(nil)
          end
        end
      end
    end
  end
end
