require 'spec_helper'

describe NcsNavigator::Authorization::StaffPortal::HttpBasic do
  let(:app) { mock('app') }
  let(:env) { { :request_headers => ::Faraday::Utils::Headers.new } }
  let(:headers) { env[:request_headers] }
  
  before { app.stub!(:call) }
  describe "token" do
    describe "for shoter passwrod" do
      subject { NcsNavigator::Authorization::StaffPortal::HttpBasic.new(app, 'user', 'pwd') }
      it 'adds the appropriate Authorization header' do
        subject.call(env)
        headers['Authorization'].should == 'Basic dXNlcjpwd2Q='
      end
    end

    describe "for longer passwrod" do
      subject { NcsNavigator::Authorization::StaffPortal::HttpBasic.new(app, 'user', 'a' * 46) }
      it 'adds the appropriate Authorization header' do
        subject.call(env)
        headers['Authorization'].should == 'Basic dXNlcjphYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFh'
      end
    end
  end
end