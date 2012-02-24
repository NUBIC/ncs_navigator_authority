require 'spec_helper'
require 'aker'
require 'vcr'
require 'faraday'
require 'faraday_stack'

describe NcsNavigator::Authorization::Psc::Authority do
  before do
    @psc_authority = NcsNavigator::Authorization::Psc::Authority.new
  end

  describe "user" do
    before do
      VCR.use_cassette('staff_portal/psc/get_staff_by_numeric_id') do
        @return_user = @psc_authority.user(1234)
      end
    end
    
    it "has id" do
      @return_user[:id].should == 1234
    end
    
    it "has username" do
      @return_user[:username].should == "testuser"
    end
    
    it "has email_address" do
      @return_user[:email_address].should == "testuser@test.com"
    end
    
    it "has first_name" do
      @return_user[:first_name].should == "TestFirstName"
    end
    
    it "has last_name" do
      @return_user[:last_name].should == "TestLastName"
    end
    
    it "has roles" do
      @return_user[:roles].should_not be_empty
      @return_user[:roles].count.should == 13
    end
    
    describe "roles hash" do
      [:study_creator, :study_calendar_template_builder, :study_qa_manager, :study_site_participation_administrator, 
        :system_administrator, :data_importer, :business_administrator, :person_and_organization_information_manager].each do |key|
        it "has #{key} if staff portal user has 'System Administrator' role" do
          @return_user[:roles].has_key?(key).should == true
        end
      end
      
      it "has user_administrator if staff portal user has 'User Administrator' role" do
        @return_user[:roles].has_key?(:user_administrator).should == true
      end
      
      it "has study_team_administrator if staff portal user has 'Staff Supervisor' role" do
        @return_user[:roles].has_key?(:study_team_administrator).should == true
      end
      
      it "has study_subject_calendar_manager if staff portal user has 'Biological Specimen Collector' role" do
        @return_user[:roles].has_key?(:study_subject_calendar_manager).should == true
      end
      
      it "has data_reader if staff portal user has 'Data Manager' role" do
        @return_user[:roles].has_key?(:data_reader).should == true
      end
      
      [:subject_manager, :study_subject_calendar_manager].each do |key|
        it "has #{key} if staff portal user has 'Field Staff' role" do
          @return_user[:roles].has_key?(key).should == true
        end
      end
      
      [:subject_manager, :study_subject_calendar_manager].each do |key|
        it "has #{key} if staff portal user has 'Phone Staff' role" do
          @return_user[:roles].has_key?(key).should == true
        end
      end
    end
    
    it "does nothing for an unknown user and return nil" do
      VCR.use_cassette('staff_portal/psc/get_unknown_staff') do
        @return_user = @psc_authority.user("unknown")
      end
      @return_user.should == nil
    end
  end
  
  describe "get_user_by_username" do
    describe "for valid username" do
      before do
        VCR.use_cassette('staff_portal/psc/get_staff_by_username') do
          @return_user = @psc_authority.get_user_by_username("testuser", nil)
        end
      end
      it "return user_hash for user with known username" do
        @return_user.should_not == nil
      end
    
      [:username, :id, :first_name, :email_address, :first_name, :last_name, :roles].each do |key|
        it "has #{key}" do
          @return_user.has_key?(key).should == true
        end
      end
    end
    
    it "returns nil for unknown username" do
      VCR.use_cassette('staff_portal/psc/get_unknown_staff') do
        @return_user = @psc_authority.get_user_by_username("unknown", nil)
      end
      @return_user.should == nil
    end
  end
  
  describe "get_user_by_id" do
    describe "for valid id" do
      before do
        VCR.use_cassette('staff_portal/psc/get_staff_by_numeric_id') do
          @return_user = @psc_authority.get_user_by_id(1234, nil)
        end
      end
    
      it "return user_hash for user with known username" do
        @return_user.should_not == nil
      end
    
      [:username, :id, :first_name, :email_address, :first_name, :last_name, :roles].each do |key|
        it "has #{key}" do
          @return_user.has_key?(key).should == true
        end
      end
    end
    
    it "returns nil for unknown username" do
      VCR.use_cassette('staff_portal/psc/get_unknown_staff') do
        @return_user = @psc_authority.get_user_by_id("unknown", nil)
      end
      @return_user.should == nil
    end
  end
end