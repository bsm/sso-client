require 'spec_helper'

describe Bsm::Sso::Client::Strategies::Ticket do

  def strategy(params = {})
    described_class.new(env_with_params('/', params))
  end

  it { expect(strategy).to be_a(described_class) }

  it "should be valid when ticket is given" do
    expect(strategy).not_to be_valid
    expect(strategy(ticket: "")).not_to be_valid
    expect(strategy(ticket: "ST-1234-ABCD")).to be_valid
  end

  it "should authenticate user via consume" do
    expect(Bsm::Sso::Client.user_class).to receive(:sso_consume).with('T', 'http://example.org/').and_return(Bsm::Sso::Client.user_class.new(id: 123))
    expect(strategy(ticket: "T").authenticate!).to eq(:success)
  end

  it "should fail authentication authenticate if user is not consumable" do
    expect(Bsm::Sso::Client.user_class).to receive(:sso_consume).with('T', 'http://example.org/').and_return(nil)
    expect(strategy(ticket: "T").authenticate!).to eq(:failure)
  end

end
