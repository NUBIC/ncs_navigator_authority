require 'buildr/bnd'
require 'buildr-gemjar'

define 'ncs_navigator_authority_gems' do
  project.version = '1.0.0'
  package(:gemjar).with_gem(:file => _('ncs_navigator_authority-1.0.0.gem')).with_gem('jruby-openssl', '0.7.5')
end