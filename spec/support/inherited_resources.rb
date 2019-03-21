class ApplicationController < ActionController::Base; end

$LOAD_PATH.unshift File.join(Gem::Specification.find_by_name('inherited_resources').gem_dir, 'app', 'controllers')
require 'inherited_resources'
require 'inherited_resources/base'
