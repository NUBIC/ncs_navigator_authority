require 'rspec'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ncs_navigator/configuration'
NcsNavigator.configuration =
  NcsNavigator::Configuration.new(File.expand_path('../navigator.ini', __FILE__))

require 'ncs_navigator/core/authority'
require 'ncs_navigator/psc/authority'

require 'spec/support/vcr_setup.rb'
RSpec.configure do |config|
# config.fixture_path = "/spec/fixtures"
end