require 'ncs_navigator/configuration'
module NcsNavigator::Authorization::Core
  class Authority
    attr_reader :logger

    def initialize(options = {})
      @logger = options[:logger] || Logger.new($stderr)
      @groups = {}
      @portal = :NCSNavigator
    end

    def amplify!(user)
      base = user(user)
      return user unless base
      user.merge!(base)
    end

    def user(user)
      staff = get_staff(user)
      if staff
        u = Aker::User.new(user.username)
        u.portals << @portal
        attributes = ["first_name", "last_name", "email"]
        attributes.each do |a|
          setter = "#{a}="
          if u.respond_to?(setter)
            u.send(setter, staff[a])
          end
        end
        u.identifiers[:staff_id] = staff["staff_id"]
        groups = staff['roles'].collect do |role|
          role['name']
        end

        if groups
          u.group_memberships(@portal).concat(load_group_memberships(@portal, groups))
        end
        u
      else
        nil
      end
    end

    def find_users(*criteria)
      return [] unless criteria.empty?
      result = []
      if users = get_users
        users.each do |u|
          next if u["username"].blank?
          au = Aker::User.new(u["username"])
          au.identifiers[:staff_id] = u["staff_id"]
          au.first_name = u["first_name"]
          au.last_name  = u["last_name"]
          result << au
        end
      end
      result
    end

    def staff_portal_uri
      NcsNavigator.configuration.staff_portal_uri
    end

    private

    def get_connection(user)
      connection = staff_portal_client(create_authenticator(user)).connection
    end

    def staff_portal_client(authenticator)
      NcsNavigator::Authorization::StaffPortal::Client.new(staff_portal_uri, :authenticator => authenticator)
    end

    def create_authenticator(user)
      { :token => lambda { user.cas_proxy_ticket(staff_portal_uri) } }
    end

    def machine_authenticator
      { :basic => ["psc_application", NcsNavigator.configuration.staff_portal['psc_user_password']] }
    end

    def load_group_memberships(portal, group_data)
      group_data.collect do |group|
        Aker::GroupMembership.new(find_or_create_group(portal, group))
      end
    end

    def find_or_create_group(portal, group_name)
      existing = (@groups[portal] ||= []).collect { |top|
        top.find { |g| g.name == group_name }
      }.compact.first
      return existing if existing
      @groups[portal] << Aker::Group.new(group_name)
      @groups[portal].last
    end

    def get_staff(user)
      connection = get_connection(user)
      response = make_request(connection, '/staff/' << user.username << '.json')
      if response.status == 200
        response.body
      else
        nil
      end
    end

    def make_request(connection, url)
      connection.get(url)
    end

    def get_users
      users = nil
      begin
        connection = staff_portal_client(machine_authenticator).connection
        response = make_request(connection, '/users.json')
        if response.status == 200
          users = response.body
        else
          logger.warn("#{Time.now}: Staff Portal Response: #{response.body}")
        end
      rescue => e
        logger.error("#{Time.now} : Staff Portal: #{e.class} #{e}")
      end
      users
   end
  end
end
