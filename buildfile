require 'buildr/bnd'
require 'buildr-gemjar'

define 'ncs_navigator_authority_gems' do
  project.version = '0.0.2.DEV'
  package(:gemjar).with_gem(:file => _('ncs_navigator_authority-0.0.2.gem')).with_gem('jruby-openssl', '0.7.5')
end