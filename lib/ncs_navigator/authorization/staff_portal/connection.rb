require 'faraday'
require 'faraday_middleware'

module NcsNavigator::Authorization::StaffPortal
  class Connection < ::Faraday::Connection
      def initialize(url, options)
        super do |builder|
          builder.use *authentication_middleware(options[:authenticator])
          builder.request :json
          builder.use FaradayMiddleware::ParseJson, :content_type => 'application/json'
          builder.adapter :net_http
        end
      end

      private

      def authentication_middleware(authenticator)
        unless authenticator
          raise 'No authentication method specified. Please include the :authenticator option.'
        end

        kind = authenticator.keys.first

        case kind
        when :basic
          [NcsNavigator::Authorization::StaffPortal::HttpBasic, *authenticator[kind]]
        when :token
          [NcsNavigator::Authorization::StaffPortal::AkerToken, authenticator[kind]]
        else
          raise "Unsupported authentication method #{kind.inspect}."
        end
      end
    end
end
