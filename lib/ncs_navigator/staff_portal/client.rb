module NcsNavigator::StaffPortal
  class Client
      attr_reader :connection
      def initialize(url, options, &block)
        @connection = NcsNavigator::StaffPortal::Connection.new(url, options, &block)
      end
    end
end