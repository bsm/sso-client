class Bsm::Sso::Client::User < Bsm::Sso::Client::AbstractResource

  class << self

    def all(options={})
      get('/users', options.reverse_merge(expects: [200, 404, 422], collection: true))
    end

    def sso_find(id)
      Bsm::Sso::Client.cache_store.fetch "users:#{id}", expires_in: Bsm::Sso::Client.expire_after do
        get "/users/#{id}", expects: [200, 404, 422]
      end
    end

    def sso_consume(ticket, service)
      get '/consume', query: { ticket: ticket, service: service }
    end

    def sso_authorize(token)
      get '/authorize', query: { auth_token: token }
    end

    def sso_authenticate(credentials)
      get '/authenticate', query: credentials.slice(:email, :password)
    end

    def sso_sign_in_url(params={})
      sso_custom_absolute_method_root_url(:sign_in, params)
    end

    def sso_sign_out_url(params={})
      sso_custom_absolute_method_root_url(:sign_out, params)
    end

    private

    def sso_custom_absolute_method_root_url(method_name, params={})
      conn = site.data
      port = ''
      unless conn[:port].blank? || (conn[:scheme] == 'http' && conn[:port].to_i == 80) || (conn[:scheme] == 'https' && conn[:port].to_i == 443)
        port = ":#{conn[:port]}"
      end

      url = "#{conn[:scheme]}://#{conn[:host]}#{port}/#{method_name}"
      url << "?#{params.to_h.to_query}" unless params.empty?
      url
    end

  end
end
