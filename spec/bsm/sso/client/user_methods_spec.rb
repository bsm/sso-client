require 'spec_helper'

describe Bsm::Sso::Client::UserMethods do

  class TestCustomUserRecord < Hash
    include Bsm::Sso::Client::UserMethods

    def initialize(attrs)
      super()
      update(attrs) if attrs
    end
  end

  subject { TestCustomUserRecord }

  before do
    stub_request(:any, //).to_return(body: '{"id":1}')
  end

  it 'should delegate methods to the user resource' do
    expect(subject.sso_find('1')).to be_a(described_class)
    expect(subject.sso_consume('T', 'S')).to be_a(described_class)
    expect(subject.sso_authorize('TOK')).to be_a(described_class)
    expect(subject.sso_authenticate(email: 'e', password: 'p')).to be_a(described_class)
    expect(subject.sso_sign_in_url).to eq('https://sso.test.host/sign_in')
    expect(subject.sso_sign_out_url).to eq('https://sso.test.host/sign_out')
  end

end
