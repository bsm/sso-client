$TESTING = true # rubocop:disable Style/GlobalVars
$LOAD_PATH.unshift File.dirname(__FILE__)
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
ENV['RAILS_ENV'] ||= 'test'

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'rspec/its'
require 'webmock/rspec'
require 'active_record'
require 'shoulda/matchers'
WebMock.disable_net_connect!

require 'rails'
require 'bsm/sso/client'

Dir[File.join(File.dirname(__FILE__), 'support', '**/*.rb')].each do |f|
  require f
end

Bsm::Sso::Client.site = 'https://sso.test.host'
Bsm::Sso::Client.expire_after = 1.hour

RSpec.configure do |c|
  c.include(Bsm::Sso::Client::SpecHelpers)

  c.before do
    allow(Bsm::Sso::Client).to receive_messages secret: 'SECRET'
  end
end

ActiveRecord::Base.configurations['test'] = { 'adapter' => 'sqlite3', 'database' => ':memory:' }
ActiveRecord::Base.establish_connection(:test)
ActiveRecord::Base.connection.create_table :users do |t|
  t.string  :email
  t.string  :kind
  t.integer :level
  t.string  :authentication_token
  t.text    :roles
  t.timestamps null: false
end

class User < ActiveRecord::Base
  include Bsm::Sso::Client::Cached::ActiveRecord
  serialize :roles, Array

  def employee?
    level >= 60
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
