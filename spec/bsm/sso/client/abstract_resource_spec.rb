require 'spec_helper'

describe Bsm::Sso::Client::AbstractResource do

  subject do
    described_class.new "email" => "noreply@example.com"
  end

  before do
    allow(Bsm::Sso::Client.verifier).to receive_messages generate: "TOKEN"
  end

  it 'should use site from configuration' do
    site = described_class.site
    expect(site).to be_instance_of(Excon::Connection)
    expect(site.data[:host]).to eq("sso.test.host")
    expect(site.data[:idempotent]).to be(true)
    expect(site.data[:headers]).to eq({ "Accept"=>"application/json", "Content-Type"=>"application/json" })
  end

  it 'should set default headers using secret' do
    headers = described_class.headers
    expect(headers).to eq({"Authorization"=>"TOKEN"})
  end

  it 'should get remote records' do
    request = stub_request(:get, "https://sso.test.host/users/123?b=2").
      with(headers: {
        'Accept'=>'application/json',
        'Authorization'=>'TOKEN',
        'Content-Type'=>'application/json',
        'Host'=>'sso.test.host:443',
        'a' => 1
      }).to_return status: 200, body: %({ "id": 123 })

    result  = described_class.get("/users/123", headers: { 'a' => 1 }, query: { 'b' => 2 })
    expect(result).to be_instance_of(described_class)
    expect(result).to eq({ "id" => 123 })
    expect(result.id).to eq(123)

    expect(request).to have_been_made
  end

  it 'should not fail on error known responses' do
    request = stub_request(:get, "https://sso.test.host/users/1").to_return status: 422
    expect(described_class.get("/users/1")).to be(nil)
    expect(request).to have_been_made
  end

  it 'should get remote collection' do
    request = stub_request(:get, "https://sso.test.host/users?b=2").
      with(headers: {
        'Accept'=>'application/json',
        'Authorization'=>'TOKEN',
        'Content-Type'=>'application/json',
        'Host'=>'sso.test.host:443',
        'a' => 1
      }).to_return status: 200, body: %([{ "id": 123 }])

    result  = described_class.get("/users", headers: { 'a' => 1 }, query: { 'b' => 2 }, collection: true)
    expect(result).to be_an(Array)
    expect(result.first).to be_instance_of(described_class)
    expect(result.first).to eq({ "id" => 123 })
    expect(result.first.id).to eq(123)

    expect(request).to have_been_made
  end

  it { is_expected.to be_a(Hash) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:email=) }
  it { is_expected.to respond_to(:email?) }
  it { is_expected.not_to respond_to(:name) }
  it { is_expected.not_to respond_to(:name=) }
  it { is_expected.not_to respond_to(:name?) }

  its(:email)  { should == "noreply@example.com" }
  its(:email?) { should == "noreply@example.com" }
  its(:name?)  { should be_nil }
  its(:attributes) { should be_instance_of(described_class) }
  its(:attributes) { should == {"email"=>"noreply@example.com"} }

  it 'should allow attribute assignment' do
    subject.email = "new@example.com"
    expect(subject.email).to eq("new@example.com")

    subject.name  = "Name"
    expect(subject.name).to eq("Name")
  end

  it 'should should have string attributes' do
    expect(described_class.new(id: 1)).to eq({"id" => 1})
  end

  it 'can be blank' do
    expect(described_class.new).to eq({})
  end

end
