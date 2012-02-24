module NcsNavigator::Authorization::StaffPortal
  class Client
      attr_reader :connection
      def initialize(url, options, &block)
        @connection = NcsNavigator::Authorization::StaffPortal::Connection.new(url, options, &block)
      end
    end
end