require 'buildr/bnd'
require 'buildr-gemjar'

define 'ncs_navigator_authority_gems' do
  project.version = '0.0.1.DEV'
  package(:gemjar).with_gem(:file => _('ncs_navigator_authority-0.0.1.gem'))
end