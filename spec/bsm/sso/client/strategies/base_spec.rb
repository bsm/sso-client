require 'spec_helper'

describe Bsm::Sso::Client::Strategies::Base do

  subject do
    described_class.new(env_with_params)
  end

  it { is_expected.to be_a(described_class) }

  it 'should reference user class' do
    expect(subject.user_class).to eq(Bsm::Sso::Client::User)
  end

end
