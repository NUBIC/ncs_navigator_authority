require 'ncs_navigator/configuration'
module NcsNavigator::Authorization::Psc
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
      users_hash(get_users_collection_by_role(role_name))
    end

    def search_users(criteria)
      users = users_hash(get_users_by_search_criteria(criteria))
      p users
      users
    end
    
    def user(staff)
      user_hash(get_user_by_username_or_id(staff))
    end
    
    private
    
      def users_hash(users)
        users_hash = []
        users.each do |u|
          users_hash << user_hash(u)
        end
        users_hash
      end

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
      
      def generate_roles_hash(sp_role)
        roles = {}
        role_mappings = RoleMapping.staff_portal_to_psc(sp_role)
        role_mappings.each do |role|
          roles[role] = true
        end
        roles
      end
    
      def staff_portal_client
        NcsNavigator::Authorization::StaffPortal::Client.new(NcsNavigator.configuration.staff_portal_uri, :authenticator => create_authenticator)
      end
    
      def create_authenticator
        { :basic => ["psc_application", NcsNavigator.configuration.staff_portal['psc_user_password']] }
      end
    
      def get_staff(url)
        response = @staff_portal_connection.get url
        if response.status == 200
          response.body
        else
          nil
        end
      end
      
      def get_user_by_username_or_id(staff)
        url = '/staff/' << staff.to_s << '.json'
        get_staff(url)
      end
      
      def get_users_collection_by_role(psc_role)
        roles = RoleMapping.psc_to_staff_portal(psc_role)
        return roles if roles.empty?
        query = 'role[]='
        roles.each_with_index do |r, i|
          query << r
          unless r == roles.last
            query << '&role[]='
          end
        end
        url = '/users.json?' << query
        get_staff(url)
      end
      
      def get_users_by_search_criteria(criteria)
        url = '/users.json'
        unless criteria.empty?
          url << "?" << construct_query(criteria)
        end
        get_staff(url)
      end
      
      def construct_query(criteria)
        operator = "&"
        if criteria.has_key?(:first_name_substring)
          query = get_search_query("first_name", criteria[:first_name_substring])
          if criteria.has_key?(:last_name_substring)
            query << operator
            query << get_search_query("last_name", criteria[:last_name_substring])
          end
          if criteria.has_key?(:username_substring)
            query << operator
            query << get_search_query("username", criteria[:username_substring])
          end
        elsif criteria.has_key?(:last_name_substring)
          query = get_search_query("last_name", criteria[:last_name_substring])
          if criteria.has_key?(:username_substring)
            query << operator
            query << get_search_query("username", criteria[:username_substring])
          end
        elsif criteria.has_key?(:username_substring)
          query = get_search_query("username", criteria[:username_substring])
        end
        query << "&operator=OR" if criteria.size > 1
        query
      end
      
      def get_search_query(key, value)
        query = "#{key}=" << value
      end
  end
  
  class RoleMapping
    def self.psc_to_staff_portal(psc_role)
      roles = [];
      case psc_role
      when :study_calendar_template_builder, :study_creator, :study_qa_manager, :study_site_participation_administrator, :system_administrator, 
        :data_importer, :business_administrator, :person_and_organization_information_manager
        roles << "System Administrator"
      when :user_administrator
        roles << "User Administrator"
      when :study_team_administrator
        roles << "Staff Supervisor"
      when :data_reader
        roles << "Data Manager"
      when :subject_manager  
        roles << "Field Staff"
        roles << "Phone Staff"
      when :study_subject_calendar_manager  
        roles << "Field Staff"
        roles << "Phone Staff"
        roles << "Biological Specimen Collector"
      end
      roles
    end
    
    def self.staff_portal_to_psc(sp_role)
      roles = [];
      case sp_role
      when "System Administrator"
        roles << :study_creator
        roles << :study_calendar_template_builder
        roles << :study_qa_manager
        roles << :study_site_participation_administrator
        roles << :system_administrator
        roles << :data_importer
        roles << :business_administrator
        roles << :person_and_organization_information_manager
      when "User Administrator"
        roles << :user_administrator
      when "Staff Supervisor"
        roles << :study_team_administrator
      when "Field Staff", "Phone Staff"
         roles << :subject_manager
         roles << :study_subject_calendar_manager
      when "Biological Specimen Collector"
        roles << :study_subject_calendar_manager
      when "Data Manager"
         roles << :data_reader
      end
      roles
    end
  end
  
end