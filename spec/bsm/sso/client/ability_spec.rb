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

    it { should have(2).roles }

    describe "roles" do
      subject { Bsm::Sso::Client::TestAbility.roles }
      it { should be_instance_of(Hash) }
      its(:keys) { should =~ [:employee, :client] }
      its([:employee]) { should have(4).items }
      its([:client])   { should have(3).items }
    end

    it 'should define role methods' do
      subject.should have(7).private_instance_methods(false)
      subject.private_instance_methods(false).should include(:"as__client__main:role")
    end
  end

  its(:scope) { should == :client }
  its(:applied) { should == ["main:role", "sub:role"].to_set }

  it 'should apply roles only once' do
    subject.same_as("main:role").should be(false)
    subject.same_as("sub:role").should be(false)
    subject.same_as("other:role").should be(true)
  end

  it 'should not allow role application from different scopes' do
    subject.send("as__employee__other:role").should be(false)
    subject.send("as__client__other:role").should be(true)
  end

  it 'should apply generic any role to ALL users (if defined)' do
    subject.is_any.should be_nil
    Bsm::Sso::Client::TestAbility.new(employee).is_any.should be(true)
    Bsm::Sso::Client::TestAbility.new(admin).is_any.should be(true)
  end

  it 'should retract any generic addition if specified by other roles' do
    subject.is_any.should be_nil
    Bsm::Sso::Client::TestAbility.new(restrictive).is_any.should be_nil
    Bsm::Sso::Client::TestAbility.new(admin).is_any.should be(true)
  end

  it 'should apply generic administrator role to admin users (if defined)' do
    subject.is_admin.should be_nil
    Bsm::Sso::Client::TestAbility.new(employee).is_admin.should be_nil
    Bsm::Sso::Client::TestAbility.new(admin).is_admin.should be(true)
  end
end