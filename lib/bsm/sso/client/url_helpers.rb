module Bsm::Sso::Client::UrlHelpers

  def service_url(path = request.fullpath)
    part = Regexp.escape({ ticket: params.fetch(:ticket, '') }.to_query)
    request.base_url + path.sub(/#{part}\&?/, '').chomp("&").chomp("?")
  end

end
