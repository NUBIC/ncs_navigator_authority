require 'spec_helper'
require 'aker'
require 'vcr'
require 'faraday'
require 'faraday_stack'
describe NcsNavigator::Authorization::Core::Authority do
 
  before do
    @ncs_navigator_authority = NcsNavigator::Authorization::Core::Authority.new
    @user = mock(:username => "lee", :cas_proxy_ticket => "PT-cas-ticket")
  end
  
  describe "user" do
    before do
      VCR.use_cassette('staff_portal/core/user') do
        @return_user = @ncs_navigator_authority.user(@user)
      end
    end
    
    it "copies first name from staff portal user" do
      @return_user.first_name.should == "Lee"
    end
    
    it "copies last name from staff portal user" do
      @return_user.last_name.should == "Peterson"
    end
    
    it "copies email from staff portal user" do
      @return_user.email.should == "lee@test.com"
    end
    
    it "generate group membership from staff role" do
      @return_user.group_memberships(:NCSNavigator).include?("Staff Supervisor").should be_true
    end
  end
  
  
  describe "#amplify!" do
    before do
      @lee = mock(Aker::User, :username => "lee", :cas_proxy_ticket => "PT-cas-ticket",:first_name => "Lee", :portals => [:NCSNavigator])
      @before_lee = mock(Aker::User, :username => "lee", :cas_proxy_ticket => "PT-cas-ticket", :merge! => @lee)
    end
  
    def actual
      VCR.use_cassette('staff_portal/core/user') do
        @ncs_navigator_authority.amplify!(@before_lee)
      end
    end

    it "copies simple attributes" do
      actual.first_name.should == "Lee"
    end
    
    it "copies portal" do
      actual.portals.should == [:NCSNavigator]
    end
    
    it "does nothing for an unknown user" do
      VCR.use_cassette('staff_portal/core/unknown_user') do
        lambda { @ncs_navigator_authority.amplify!(mock(Aker::User, :username => "lees", :cas_proxy_ticket => "PT-cas-ticket"))}.should_not raise_error
      end
    end
  end
  
end
