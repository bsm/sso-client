require 'spec_helper'

describe Bsm::Sso::Client::Strategies::HttpAuth do

  def strategy(authorization=nil)
    env = {}
    env['HTTP_AUTHORIZATION'] = authorization if authorization
    described_class.new(env_with_params('/', {}, env))
  end

  it { expect(strategy).to be_a(described_class) }

  it 'should be valid when authorization token is given' do
    expect(strategy).not_to be_valid
    expect(strategy('')).not_to be_valid
    expect(strategy('WRONG!')).not_to be_valid
    expect(strategy("Basic dXNlcjp4\n")).to be_valid
  end

  it 'should not remember user' do
    expect(strategy).not_to be_store
  end

  it 'should extract token' do
    expect(strategy.token).to be_nil
    expect(strategy('').token).to be_nil
    expect(strategy('WRONG!').token).to be_nil
    expect(strategy("Basic dXNlcjp4\n").token).to eq('user')
  end

  it 'should authenticate user via authorize' do
    expect(Bsm::Sso::Client.user_class).to receive(:sso_authorize).with('user').and_return(Bsm::Sso::Client.user_class.new(id: 123))
    expect(strategy("Basic dXNlcjp4\n").authenticate!).to eq(:success)
  end

  it 'should fail authentication authenticate if user is not authorizable' do
    expect(Bsm::Sso::Client.user_class).to receive(:sso_authorize).with('user').and_return(nil)
    expect(strategy("Basic dXNlcjp4\n").authenticate!).to eq(:failure)
  end

end
