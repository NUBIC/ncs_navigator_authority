require 'spec_helper'
require 'aker'
require 'vcr'

describe NcsNavigator::Authorization::Psc::Authority do
  before do
    @psc_authority = NcsNavigator::Authorization::Psc::Authority.new
  end

  describe "user" do
    before do
      VCR.use_cassette('staff_portal/psc/user_by_numeric_id') do
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
      VCR.use_cassette('staff_portal/psc/unknown_user') do
        @return_user = @psc_authority.user("unknown")
      end
      @return_user.should == nil
    end
  end
  
  describe "get_user_by_username" do
    describe "for valid username" do
      before do
        VCR.use_cassette('staff_portal/psc/user_by_username') do
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
      VCR.use_cassette('staff_portal/psc/unknown_user') do
        @return_user = @psc_authority.get_user_by_username("unknown", nil)
      end
      @return_user.should == nil
    end
  end
  
  describe "get_user_by_id" do
    describe "for valid id" do
      before do
        VCR.use_cassette('staff_portal/psc/user_by_numeric_id') do
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
      VCR.use_cassette('staff_portal/psc/unknown_user') do
        @return_user = @psc_authority.get_user_by_id("unknown", nil)
      end
      @return_user.should == nil
    end
  end
  
  describe "get_users_by_role" do
    it "returns empty array for unknown role" do
      return_users = @psc_authority.get_users_by_role(:unknown)
      return_users.should be_empty
    end
    
    describe "for valid role" do
      before do
        VCR.use_cassette('staff_portal/psc/users_by_role') do
          @return_users = @psc_authority.get_users_by_role(:subject_manager)
        end
      end
    
      it "returns users with roles" do
        @return_users.count.should == 2
      end
    
      [:username, :id, :first_name, :email_address, :last_name, :roles].each do |key|
        it "has #{key}" do
          @return_users[0].has_key?(key).should == true
        end
      end
      
      it "returns empty array if no users with role" do
        VCR.use_cassette('staff_portal/psc/empty_users_by_role') do
          @return_users = @psc_authority.get_users_by_role(:subject_manager)
        end
        @return_users.should be_empty
      end

      it "excludes the user with null username from list of users returning" do
        VCR.use_cassette('staff_portal/psc/users_with_null_username') do
          @return_users = @psc_authority.get_users_by_role(:subject_manager)
        end
        @return_users.count.should == 1
      end
    end    
  end
  
  describe "search_users" do
    it "returns all the users for empty hash" do
      VCR.use_cassette('staff_portal/psc/all_users') do
        @return_users = @psc_authority.search_users({})
      end
      @return_users.count.should == 6
    end
    
    describe "with first_name" do
      before do
        VCR.use_cassette('staff_portal/psc/users_by_first_name') do
          @return_users = @psc_authority.search_users({:first_name_substring => "an"})
        end
      end
      
      it "returns all the users with first_name criteria match" do
        @return_users.count.should == 2
      end
      
      it "has user with first_name match with criteria" do
        @return_users[0][:first_name].should == "Nolan"
        @return_users[1][:first_name].should == "Lithan"
      end
      
      [:username, :id, :first_name, :email_address, :first_name, :last_name, :roles].each do |key|
        it "user has #{key}" do
          @return_users[0].has_key?(key).should == true
        end
      end
    end
    
    describe "with last_name" do
      before do
        VCR.use_cassette('staff_portal/psc/users_by_last_name') do
          @return_users = @psc_authority.search_users({:last_name_substring => "Palbo"})
        end
      end
      
      it "returns all the users with last_name criteria match" do
        @return_users.count.should == 1
      end
      
      it "has user with last_name match with criteria" do
        @return_users[0][:last_name].should == "Palbo"
      end
    end
    
    describe "with username" do
      before do
        VCR.use_cassette('staff_portal/psc/users_by_username') do
          @return_users = @psc_authority.search_users({:username_substring => "gd123"})
        end
      end
      
      it "returns all the users with username criteria match" do
        @return_users.count.should == 1
      end
      
      it "has user with username match with criteria" do
        @return_users[0][:username].should == "gd123"
      end
    end
    
    describe "with first_name or last_name" do
      before do
        VCR.use_cassette('staff_portal/psc/users_by_first_or_last_name') do
          @return_users = @psc_authority.search_users({:first_name_substring => "Lithan", :last_name_substring => "Palbo"})
        end
      end
      
      it "returns all the users with first_name or last_name criteria match" do
        @return_users.count.should == 2
      end
      
      it "has user with first_name match with criteria" do
        @return_users[1][:first_name].should == "Lithan"
      end
      
      it "has user with last_name match with criteria" do
        @return_users[0][:last_name].should == "Palbo"
      end
    end
    
    describe "with first_name or username" do
      before do
        VCR.use_cassette('staff_portal/psc/users_by_first_or_user_name') do
          @return_users = @psc_authority.search_users({:first_name_substring => "Lithan", :username_substring => "gd123"})
        end
      end
      
      it "returns all the users with first_name or username criteria match" do
        @return_users.count.should == 2
      end
      
      it "has user with username match with criteria" do
        @return_users[0][:username].should == "gd123"
      end
      
      it "has user with first_name match with criteria" do
        @return_users[1][:first_name].should == "Lithan"
      end
    end
    
    describe "with last_name or username" do
      before do
        VCR.use_cassette('staff_portal/psc/users_by_last_or_user_name') do
          @return_users = @psc_authority.search_users({:last_name_substring => "Palbo", :username_substring => "gd123"})
        end
      end
      
      it "returns all the users with last_name or username criteria match" do
        @return_users.count.should == 2
      end
      
      it "has user with username match with criteria" do
        @return_users[1][:username].should == "gd123"
      end
      
      it "has user with last_name match with criteria" do
        @return_users[0][:last_name].should == "Palbo"
      end
    end
    
    describe "with first_name or last_name or username" do
      before do
        VCR.use_cassette('staff_portal/psc/users_by_first_or_last_or_user_name') do
          @return_users = @psc_authority.search_users({:first_name_substring => "Lithan", :last_name_substring => "Palbo", :username_substring => "gd123"})
        end
      end
      
      it "returns all the users with first_name or last_name or username criteria match" do
        @return_users.count.should == 3
      end
      
      it "has user with username match with criteria" do
        @return_users[1][:username].should == "gd123"
      end
      
      it "has user with last_name match with criteria" do
        @return_users[0][:last_name].should == "Palbo"
      end
      
      it "has user with first_name match with criteria" do
        @return_users[2][:first_name].should == "Lithan"
      end
    end
    
    it "returns empty array if no users with match with search criteria" do
      VCR.use_cassette('staff_portal/psc/empty_users_by_search_criteria') do
        @return_users = @psc_authority.search_users({:first_name_substring => "unknown", :last_name_substring => "unknown", :username_substring => "unknown"})
      end
      @return_users.should be_empty
    end

  end
end
