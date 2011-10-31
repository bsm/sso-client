$TESTING=true
$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'bundler/setup'
require 'webmock/rspec'
WebMock.disable_net_connect!

require 'rails'
require 'active_record'
require 'shoulda/matchers'
require 'bsm/sso/client'

Dir[File.join(File.dirname(__FILE__), "support", "**/*.rb")].each do |f|
  require f
end

Bsm::Sso::Client.site = "https://sso.test.host"
Bsm::Sso::Client.expire_after = 1.hour

RSpec.configure do |c|
  c.include(Bsm::Sso::Client::SpecHelpers)

  c.before do
    Bsm::Sso::Client.stub :secret => "SECRET"
  end
end

ActiveRecord::Base.configurations["test"] = { 'adapter' => 'sqlite3', 'database' => ":memory:" }
ActiveRecord::Base.establish_connection(:test)
ActiveRecord::Base.connection.create_table :users do |t|
  t.string  :email
  t.string  :kind
  t.integer :level
end

class User < ActiveRecord::Base
  include Bsm::Sso::Client::Cached::ActiveRecord
end