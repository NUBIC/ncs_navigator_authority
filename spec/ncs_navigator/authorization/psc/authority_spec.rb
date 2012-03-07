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
  
  describe "get_user_by_role" do
    it "returns empty array for unknown role" do
      return_user = @psc_authority.get_users_by_role(:unknown)
      return_user.should be_empty
    end
    
    describe "for valid role" do
      before do
        VCR.use_cassette('staff_portal/psc/get_staff_by_role') do
          @return_users = @psc_authority.get_users_by_role(:subject_manager)
        end
      end
    
      it "returns users with roles" do
        @return_users.count.should == 2
      end
    
      [:username, :id, :first_name, :email_address, :first_name, :last_name, :roles].each do |key|
        it "has #{key}" do
          @return_users[0].has_key?(key).should == true
        end
      end
      
      it "returns empty array if no users with role" do
        VCR.use_cassette('staff_portal/psc/get_empty_staff_by_role') do
          @return_user = @psc_authority.get_users_by_role(:subject_manager)
        end
        @return_user.should be_empty
      end
    end    
  end
end