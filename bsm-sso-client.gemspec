# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.0.0'
  s.required_rubygems_version = ">= 1.8.0"

  s.name        = "bsm-sso-client"
  s.summary     = "BSM's internal SSO client"
  s.description = ""
  s.version     = '0.9.1'

  s.authors     = ["Dimitrij Denissenko"]
  s.email       = "dimitrij@blacksquaremedia.com"
  s.homepage    = "https://github.com/bsm/sso-client"

  s.require_path = 'lib'
  s.files        = Dir['lib/**/*']

  s.add_dependency "railties", ">= 4.1.0", "< 4.2.0"
  s.add_dependency "actionpack"
  s.add_dependency "activesupport"
  s.add_dependency "rails_warden", "~> 0.5.0"
  s.add_dependency "excon", ">= 0.27.0", "< 1.0.0"

  s.add_development_dependency "cancan"
  s.add_development_dependency "activerecord"
  s.add_development_dependency "rake"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "rspec"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "webmock"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "inherited_resources"
  s.add_development_dependency "protected_attributes"

end
