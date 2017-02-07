require 'spec_helper'

describe Bsm::Sso::Client::Cached::ActiveRecord, type: :model do

  before do
    I18n.enforce_available_locales = false
  end

  subject do
    User.new
  end

  after do
    User.delete_all
    I18n.enforce_available_locales = true
  end

  let :record do
    args = [{id: 100, email: "alice@example.com", kind: "user", level: 10, authentication_token: "SECRET"}]
    args << {without_protection: true} if defined?(ProtectedAttributes)
    User.create! *args
  end

  def resource(attrs = {})
    Bsm::Sso::Client::User.new record.attributes.merge(attrs)
  end

  let :new_resource do
    Bsm::Sso::Client::User.new id: 200, email: "new@example.com"
  end

  it { is_expected.to be_a(described_class) }
  it { is_expected.to validate_presence_of(:id) }

  it 'should find records' do
    expect(User.sso_find(record.id)).to eq(record)
    expect(Bsm::Sso::Client::User).to receive(:sso_find).with(-1).and_return(nil)
    expect(User.sso_find(-1)).to be_nil
  end

  it 'should not authorize blank tokens' do
    expect(Bsm::Sso::Client::User).not_to receive(:sso_authorize)
    expect(User.sso_authorize(" ")).to be_nil
  end

  it 'should authorize as usual when user is not cached' do
    expect(Bsm::Sso::Client::User).to receive(:sso_authorize).and_return(nil)
    expect(User.sso_authorize("SECRET")).to be_nil
  end

  it 'should used cached on authorize' do
    record # Create one
    expect(Bsm::Sso::Client::User).not_to receive(:sso_authorize)
    expect(User.sso_authorize("SECRET")).to eq(record)
  end

  it 'should not use cached on authorize when expired' do
    record.update_column :updated_at, 3.hours.ago
    expect(Bsm::Sso::Client::User).to receive(:sso_authorize).and_return(nil)
    expect(User.sso_authorize("SECRET")).to be_nil
  end

  it 'should cache (and create) new records' do
    record = User.sso_cache(new_resource)
    expect(record).to be_a(User)
    expect(record).to be_persisted
    expect(record.id).to eq(200)
  end

  it 'should cache (and update) existing records when changed' do
    expect {
      expect(User.sso_cache(resource(level: 20))).to eq(record)
    }.to change { record.reload.level }.from(10).to(20)

    expect {
      expect(User.sso_cache(resource("level" => 10))).to eq(record)
    }.to change { record.reload.level }.from(20).to(10)
  end

  it 'should cache (and touch) existing records even when unchanged' do
    expect {
      expect(User.sso_cache(resource)).to eq(record)
    }.to change { record.reload.updated_at }
  end

  it 'should only cache known attributes' do
    expect {
      expect(User.sso_cache(resource(unknown: "value"))).to eq(record)
    }.to change { record.reload.updated_at }
  end

  it 'should only cache known attributes for new records' do
    record.destroy
    expect {
      User.sso_cache(resource(unknown: "value"))
    }.not_to raise_error
  end

end
