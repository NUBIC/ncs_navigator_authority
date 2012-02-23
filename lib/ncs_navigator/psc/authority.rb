require 'ncs_navigator'

module NcsNavigator::Psc
  class Authority
    def initialize(ignored_config=nil)
      @staff_portal_connection ||= staff_portal_client.connection
    end
    
    def get_user_by_username(username, role_detail_level)
      user(username)
    end
    
    def get_user_by_id(id, role_detail_level)
      user(id)
    end
        
    def get_users_by_role(role_name)
      nil
    end

    def search_users(criteria)
      nil
    end
    
    def user(staff)
      user_hash(get_staff(staff))
    end
    
    private

      def user_hash(staff)
        return nil unless staff
        {
          :username => staff["username"],
          :id =>  staff["numeric_id"],
          :email_address => staff["email"],
          :first_name => staff["first_name"],
          :last_name => staff["last_name"],
          :roles => roles_hash(staff["roles"].collect {|role| role['name']})
        }
      end
      
      def roles_hash(roles)
        roles_hash = {}
        roles.each do |role|
          roles_hash.merge!(generate_roles_hash(role))
        end
        roles_hash
      end
      
      def generate_roles_hash(role)
        roles = {}
        case role
        when "System Administrator"
          roles[:study_creator] = true
          roles[:study_calendar_template_builder] = true
          roles[:study_qa_manager] = true
          roles[:study_site_participation_administrator] = true
          roles[:system_administrator] = true
          roles[:data_importer] = true
          roles[:business_administrator] = true
          roles[:person_and_organization_information_manager] = true
        when "User Administrator"
          roles[:user_administrator] = true
        when "Staff Supervisor"
          roles[:study_team_administrator] = true
        when "Field Staff" || "Phone Staff"
          roles[:subject_manager] = true
          roles[:study_subject_calendar_manager] = true
        when "Biological Specimen Collector"
          roles[:study_subject_calendar_manager] = true
        when "Data Manager"
          roles[:data_reader] = true
        end
        roles
      end
    
      def staff_portal_client
        NcsNavigator::StaffPortal::Client.new(NcsNavigator.configuration.staff_portal_uri, :authenticator => create_authenticator)
      end
    
      def create_authenticator
        { :basic => ["psc_application", NcsNavigator.configuration.staff_portal['psc_user_password']] }
      end
    
      def get_staff(user)
        response = @staff_portal_connection.get '/staff/' << user.to_s << '.json'
        if response.status == 200
          response.body
        else
          nil
        end
      end
    
  end
end