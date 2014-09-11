begin
  require 'cancan/ability'
rescue LoadError => e
  warn "\n [!] Please install `cancan` Gem to use the Ability module\n"
  raise
end

module Bsm::Sso::Client::Ability
  extend ActiveSupport::Concern

  included do
    include CanCan::Ability
  end

  module ClassMethods

    # @return [Hash] roles, scoped by user type
    def roles
      private_instance_methods(false).inject({}) do |result, name|
        prefix, scope, name = name.to_s.split('__')
        next result unless prefix == "as" && scope && name

        result[scope.to_sym] ||= []
        result[scope.to_sym] << name
        result
      end
    end

    # Ability definition helper
    # @param [Symbol] scope the user scope
    # @param [String] name the role name
    def as(scope, name, &block)
      method_name = :"as__#{scope}__#{name}"

      define_method(method_name) do
        return false if self.scope != scope || applied.include?(name.to_s)
        applied.add(name.to_s)
        instance_eval(&block)
        true
      end
      private method_name
    end

  end

  # @attr_reader [User] current user record
  attr_reader :user

  # Construstor
  # @param [User] current user record
  def initialize(user)
    @user = user

    same_as(:any)
    @user.roles.each do |name|
      same_as(name)
    end
    same_as(:administrator) if administrator?
  end

  # @return [Symbol] the user scope
  def scope
    @scope ||= (user.respond_to?(:kind) && user.kind? ? user.kind.to_sym : :client)
  end

  # @return [Set] applied roles
  def applied
    @applied ||= Set.new
  end

  # Runs a role method
  # @param [String] name the role name
  def same_as(name)
    method = :"as__#{scope}__#{name}"
    send(method) if respond_to?(method, true)
  end

  private

    def administrator?
      (@user.respond_to?(:level?) && @user.level.to_i >= 90) || (@user.respond_to?(:admin?) && @user.admin?)
    end

end