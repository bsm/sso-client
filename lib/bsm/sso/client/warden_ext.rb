class Warden::SessionSerializer
  # Stores user id and expiration time
  def serialize(record)
    record.id
  end

  # Loads user and expiration time from session
  def deserialize(id)
    Bsm::Sso::Client.user_class.sso_find(id)
  end
end

Warden::Manager.after_set_user do |user, warden, opts|
  scope = opts[:scope]

  if user && opts[:event] == :authentication
    warden.session(scope)['expire_at'] = Bsm::Sso::Client.expire_after.from_now.to_i
  elsif opts[:event] == :fetch &&
        warden.session(scope)['expire_at'].to_i < Time.now.to_i &&
        warden.request.env['REQUEST_METHOD'] == 'GET'
    warden.logout(scope)
    throw :warden, scope: scope, message: :timeout
  end
end
