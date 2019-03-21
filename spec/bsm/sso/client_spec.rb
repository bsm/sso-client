require 'spec_helper'

describe Bsm::Sso::Client do

  it 'should be configurable' do
    described_class.configure do |c|
      expect(c).to respond_to(:site=)
      expect(c).to respond_to(:secret=)
      expect(c.site).to be_instance_of(Excon::Connection)
      expect(c.secret).to eq('SECRET')
    end
  end

  it 'should allow to configure warden' do
    expect(described_class.warden_configuration).to be_nil
    block = ->(m) {}
    described_class.warden(&block)
    expect(described_class.warden_configuration).to eq(block)
  end

  it 'should have a default user class' do
    expect(described_class.user_class).to eq(described_class::User)
  end

  it 'should allow setting user class with class' do
    klass = Class.new
    described_class.user_class = klass
    expect(described_class.user_class).to eq(klass)
  end

  it 'should allow setting user class with name' do
    described_class.user_class = 'Bsm::Sso::Client::User'
    expect(described_class.user_class).to eq(described_class::User)
  end

  it 'should have a message verifier' do
    v = described_class.verifier
    expect(v).to be_a(ActiveSupport::MessageVerifier)
    time = Time.now
    expect(v.verify(v.generate(time))).to eq(time)
  end

  it 'should have a default user class' do
    request = double 'Request', path: '/admin'
    expect { described_class.forbidden!(request) }.to raise_error(Bsm::Sso::Client::UnauthorizedAccess)
  end

  it 'should have a cache store' do
    expect(described_class.cache_store).to be_instance_of(ActiveSupport::Cache::NullStore)
    expect(described_class.cache_store.options).to eq(namespace: 'bsm:sso:client:test')
  end

end
