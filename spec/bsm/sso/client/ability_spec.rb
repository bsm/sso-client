require 'spec_helper'

describe Bsm::Sso::Client::Ability do

  class Bsm::Sso::Client::TestAbility
    include Bsm::Sso::Client::Ability

    attr_reader :is_admin, :is_any

    as :client, "main:role" do
    end

    as :client, "sub:role" do
      same_as "main:role"
    end

    as :client, "other:role" do
    end

    as :employee, "other:role" do
    end

    as :employee, "restrictive:role" do
      @is_any = nil
    end

    as :employee, "any" do
      @is_any = true
    end

    as :employee, "administrator" do
      @is_admin = true
    end
  end

  def new_user(kind, level=0, *roles)
    ::User.new.tap do |u|
      u.kind  = kind
      u.level = level
      u.roles = roles
    end
  end

  let(:client)      { new_user "client", 0, "sub:role" }
  let(:employee)    { new_user "employee", 60 }
  let(:restrictive) { new_user "employee", 60, "restrictive:role" }
  let(:admin)       { new_user "employee", 90 }

  subject do
    Bsm::Sso::Client::TestAbility.new(client)
  end

  describe "class" do
    subject { Bsm::Sso::Client::TestAbility }

    its("roles.size") { is_expected.to eq(2) }

    describe "roles" do
      subject { Bsm::Sso::Client::TestAbility.roles }
      it { is_expected.to be_instance_of(Hash) }
      its(:keys) { is_expected.to match_array([:employee, :client]) }
      it "should be identified by user type" do
        expect(subject[:employee].size).to eq(4)
        expect(subject[:client].size).to eq(3)
      end
    end

    it 'should define role methods' do
      expect(subject.private_instance_methods(false).size).to eq(7)
      expect(subject.private_instance_methods(false)).to include(:"as__client__main:role")
    end
  end

  its(:scope) { is_expected.to eq(:client) }
  its(:applied) { is_expected.to eq(["main:role", "sub:role"].to_set) }

  it 'should apply roles only once' do
    expect(subject.same_as("main:role")).to be(false)
    expect(subject.same_as("sub:role")).to be(false)
    expect(subject.same_as("other:role")).to be(true)
  end

  it 'should not allow role application from different scopes' do
    expect(subject.send("as__employee__other:role")).to be(false)
    expect(subject.send("as__client__other:role")).to be(true)
  end

  it 'should apply generic any role to ALL users (if defined)' do
    expect(subject.is_any).to be_nil
    expect(Bsm::Sso::Client::TestAbility.new(employee).is_any).to be(true)
    expect(Bsm::Sso::Client::TestAbility.new(admin).is_any).to be(true)
  end

  it 'should retract any generic addition if specified by other roles' do
    expect(subject.is_any).to be_nil
    expect(Bsm::Sso::Client::TestAbility.new(restrictive).is_any).to be_nil
    expect(Bsm::Sso::Client::TestAbility.new(admin).is_any).to be(true)
  end

  it 'should apply generic administrator role to admin users (if defined)' do
    expect(subject.is_admin).to be_nil
    expect(Bsm::Sso::Client::TestAbility.new(employee).is_admin).to be_nil
    expect(Bsm::Sso::Client::TestAbility.new(admin).is_admin).to be(true)
  end
end
