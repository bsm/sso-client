begin
  require 'inherited_resources'
rescue LoadError
  warn "\n [!] Please install `inherited_resources` Gem to use the AuthorizedController\n"
  raise
end

module Bsm::Sso::Client::AuthorizedController
  extend ActiveSupport::Concern

  included do
    before_filter :authorize_inherited_resource!
  end

  protected

  # Override. Apply `accessible_by` scope if #scope_accessible? applies
  def apply_scopes(*)
    relation = super
    relation = relation.accessible_by(current_ability) if scope_accessible?
    relation
  end

  # Callback. Default authorization of inherited resources
  def authorize_inherited_resource!
    authorize! :show, parent if parent?
    authorize! authorizable_action, authorize_resource? ? resource : resource_class
  end

  # @return [Boolean] true if a single resource is to be authorized, false if the whole resource class
  def authorize_resource?
    !!(resources_configuration[:self][:singleton] || params[:id])
  end

  # @return [Boolean] true if accessible_by scope should be applied
  def scope_accessible?
    !authorize_resource? && %w[new create].exclude?(action_name)
  end

  # @return [Symbol] resource permission name, defaults to the action name
  def authorizable_action
    action_name.to_sym
  end
end
