require 'base64'

module NcsNavigator::Authorization::StaffPortal
  class HttpBasic
    def initialize(app, username, password)
      @app = app
      @header_value = "Basic #{Base64.encode64([username, password].join(':')).strip}"
    end

    def call(env)
      env[:request_headers]['Authorization'] = @header_value

      @app.call(env)
    end
  end
end