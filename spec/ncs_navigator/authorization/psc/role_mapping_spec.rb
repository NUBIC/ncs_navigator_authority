describe NcsNavigator::Authorization::Psc::RoleMapping do
  before do
    @role_mapping = NcsNavigator::Authorization::Psc::RoleMapping
  end
  describe "psc_to_staff_portal" do
    [:study_creator, :study_calendar_template_builder, :study_qa_manager, :study_site_participation_administrator, 
      :system_administrator, :data_importer, :business_administrator, :person_and_organization_information_manager].each do |key|
      it "maps '#{key}' to 'System Administrator' role" do
        has_correct_psc_to_sp_role_mapping(key, "System Administrator")
      end
    end
    
    it "maps ':user_administrator' to 'User Administrator' role" do
      has_correct_psc_to_sp_role_mapping(:user_administrator, "User Administrator")
    end
    
    it "maps ':study_team_administrator' to 'Staff Supervisor' role" do
      has_correct_psc_to_sp_role_mapping(:study_team_administrator, "Staff Supervisor")
    end
    
    it "maps ':data_reader' to 'Data Manager' role" do
      has_correct_psc_to_sp_role_mapping(:data_reader, "Data Manager")
    end
    
    it "maps ':subject_manager' to 'Field Staff' and 'Phone Staff' roles" do
      roles = @role_mapping.psc_to_staff_portal(:subject_manager)
      roles.count.should == 2
      roles.should include "Field Staff"
      roles.should include "Phone Staff"
    end
    
    it "maps ':study_subject_calendar_manager' to 'Field Staff', 'Phone Staff' and 'Biological Specimen Collector' roles" do
      roles = @role_mapping.psc_to_staff_portal(:study_subject_calendar_manager)
      roles.count.should == 3
      roles.should include "Field Staff"
      roles.should include "Phone Staff"
      roles.should include "Biological Specimen Collector"
    end
  end
  
  describe "staff_portal_to_psc" do
    describe "maps 'System Administrator'" do
      before do
        @roles = @role_mapping.staff_portal_to_psc("System Administrator")
        @roles.count.should == 8
      end
      
      [:study_creator, :study_calendar_template_builder, :study_qa_manager, :study_site_participation_administrator, 
        :system_administrator, :data_importer, :business_administrator, :person_and_organization_information_manager].each do |key|
        it "to ':#{key}' role" do
          @roles.should include key
        end
      end
    end
    
    it "maps 'User Administrator' to ':user_administrator' role" do
      has_correct_sp_to_psc_role_mapping("User Administrator", :user_administrator)
    end
    
    it "maps 'Staff Supervisor' to ':study_team_administrator' role" do
      has_correct_sp_to_psc_role_mapping("Staff Supervisor", :study_team_administrator)
    end
    
    it "maps 'Data Manager' to ':data_reader' role" do
      has_correct_sp_to_psc_role_mapping("Data Manager", :data_reader)
    end
    
    it "maps 'Biological Specimen Collector' to ':study_subject_calendar_manager' role" do
      has_correct_sp_to_psc_role_mapping("Biological Specimen Collector", :study_subject_calendar_manager)
    end

    it "maps 'Field Staff' to ':subject_manager' and ':study_subject_calendar_manager' roles" do
      roles = @role_mapping.staff_portal_to_psc('Field Staff')
      roles.count.should == 2
      roles.should include :subject_manager
      roles.should include :study_subject_calendar_manager
    end
    
    it "maps 'Phone Staff' to ':subject_manager' and ':study_subject_calendar_manager' roles" do
      roles = @role_mapping.staff_portal_to_psc('Phone Staff')
      roles.count.should == 2
      roles.should include :subject_manager
      roles.should include :study_subject_calendar_manager
    end
  end
  
  private
    def has_correct_psc_to_sp_role_mapping(psc_role, sp_role)
      roles = @role_mapping.psc_to_staff_portal(psc_role)
      roles.count.should == 1
      roles.should include sp_role
    end
    
    def has_correct_sp_to_psc_role_mapping(sp_role, psc_role)
      roles = @role_mapping.staff_portal_to_psc(sp_role)
      roles.count.should == 1
      roles.should include psc_role
    end
end