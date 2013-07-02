require 'spec_helper'

describe ConversionLog do
  describe "#get_all_logs" do
    let!(:user) {FactoryGirl.create(:user_super)}
    let!(:promotion) {FactoryGirl.create(:promotion)}
    let!(:client) {FactoryGirl.create(:client)}
    let!(:conversion_logs) {ConversionLog.get_all_logs(1, 1, 10, "", "",
                                                  "", "03/25/2013", "06/25/2013", 0, "conversion_utime", "desc")}
                                                  
    context "with valid params" do
    
    
      subject {conversion_logs.count}
      it {should == 10}
    end
    
    context "with cv_id nil" do
      let!(:conversion_logs1) {ConversionLog.get_all_logs(1, 1, 10, 1, "",
                                                  "", "03/25/2013", "06/25/2013", 0, "conversion_utime", "desc")}
      subject {conversion_logs.count}
      it {should == 10}
    end
    
    context "with id nil" do
      let!(:conversion_logs1) {ConversionLog.get_all_logs(100, 1, 10, 1, "",
                                                  "", "03/25/2013", "06/25/2013", 0, "conversion_utime", "desc")}
      subject {conversion_logs.count}
      it {should == 10}
    end
    
    context "with account id nil" do
      let!(:conversion_logs1) {ConversionLog.get_all_logs(1, 1, 10, "", "",
                                                  1, "03/25/2013", "06/25/2013", 0, "conversion_utime", "desc")}
      subject {conversion_logs.count}
      it {should == 10}
    end
    
    context "with media_category nil" do
      let!(:conversion_logs1) {ConversionLog.get_all_logs(1, 1, 10, "", 1,
                                                  "", "03/25/2013", "06/25/2013", 0, "conversion_utime", "desc")}
      subject {conversion_logs.count}
      it {should == 10}
    end
    
    context "with show error equal 1" do
      let!(:conversion_logs1) {ConversionLog.get_all_logs(1, 1, 10, "", "",
                                                  "", "03/25/2013", "06/25/2013", "1", "conversion_utime", "desc")}
      subject {conversion_logs.count}
      it {should == 10}
    end
  end
  
  describe "#get_logs" do
    let!(:user) {FactoryGirl.create(:user_super)}
    let!(:promotion) {FactoryGirl.create(:promotion)}
    let!(:client) {FactoryGirl.create(:client)}
    let!(:conversion_logs) {ConversionLog.get_logs(1, "", "",
                                                  "", "03252013", "06252013", 0)}
                                                  
    context "with valid params" do
    
    
      subject {conversion_logs.count}
      it {should == 0}
    end
    
    context "with cv_id nil" do
      let!(:conversion_logs1) {ConversionLog.get_logs(1, 1, "",
                                                  "", "03252013", "06252013", 0)}
      subject {conversion_logs.count}
      it {should == 0}
    end
    
    context "with id nil" do
      let!(:conversion_logs1) {ConversionLog.get_logs(100, 1, "",
                                                  "", "03252013", "06252013", 0)}
      subject {conversion_logs.count}
      it {should == 0}
    end
    
    context "with account id nil" do
      let!(:conversion_logs1) {ConversionLog.get_logs(1, "", "",
                                                  1, "03052013", "06252013", 0)}
      subject {conversion_logs.count}
      it {should == 0}
    end
    
    context "with media_category nil" do
      let!(:conversion_logs1) {ConversionLog.get_logs(1,"", 1,
                                                  "", "03252013", "06252013", 0)}
      subject {conversion_logs.count}
      it {should == 0}
    end
    
    context "with show error equal 1" do
      let!(:conversion_logs1) {ConversionLog.get_logs(1, "", "",
                                                  "", "03252013", "06252013", "1")}
      subject {conversion_logs.count}
      it {should == 0}
    end
  end
  
  describe "#get_count" do
    let!(:user) {FactoryGirl.create(:user_super)}
    let!(:promotion) {FactoryGirl.create(:promotion)}
    let!(:client) {FactoryGirl.create(:client)}
    let!(:conversion_logs) {ConversionLog.get_count(1, "", "",
                                                  "", "03/25/2013", "06/25/2013", 0)}
                                                  
    context "with valid params" do
    
    
      subject {conversion_logs}
      it {should > 0}
    end
    
    context "with cv_id nil" do
      let!(:conversion_logs1) {ConversionLog.get_count(1, 1, "",
                                                  "", "03/25/2013", "06/25/2013", 0)}
      subject {conversion_logs}
      it {should > 0 }
    end
    
    context "with id nil" do
      let!(:conversion_logs1) {ConversionLog.get_count(100, 1, "",
                                                  "", "03/25/2013", "06/25/2013", 0)}
      subject {conversion_logs}
      it {should > 0}
    end
    
    context "with account id nil" do
      let!(:conversion_logs1) {ConversionLog.get_count(1, "", "",
                                                  1, "03/25/2013", "06/25/2013", 0)}
      subject {conversion_logs}
      it {should > 0}
    end
    
    context "with media_category nil" do
      let!(:conversion_logs1) {ConversionLog.get_count(1,"", 1,
                                                  "", "03/25/2013", "06/25/2013", 0)}
      subject {conversion_logs}
      it {should > 0}
    end
    
    context "with show error equal 1" do
      let!(:conversion_logs1) {ConversionLog.get_count(1, "", "",
                                                  "", "03/25/2013", "06/25/2013", "1")}
      subject {conversion_logs}
      it {should > 0}
    end
  end
end