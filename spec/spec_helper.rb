require 'rspec'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ncs_navigator/configuration'
NcsNavigator.configuration =
  NcsNavigator::Configuration.new(File.expand_path('../navigator.ini', __FILE__))

require 'ncs_navigator/authorization/core/authority'
require 'ncs_navigator/authorization/psc/authority'
require 'ncs_navigator/authorization/staff_portal/aker_token'
require 'ncs_navigator/authorization/staff_portal/client'
require 'ncs_navigator/authorization/staff_portal/connection'
require 'ncs_navigator/authorization/staff_portal/http_basic'

require 'spec/support/vcr_setup.rb'
RSpec.configure do |config|
# config.fixture_path = "/spec/fixtures"
end