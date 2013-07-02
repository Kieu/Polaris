require 'spec_helper'

describe DailySummaryAccount do
  let!(:client){FactoryGirl.create(:client)}
  let!(:account){ FactoryGirl.create(:account)}
  let!(:media){ FactoryGirl.create(:media)}
  let!(:promotion) {FactoryGirl.create(:promotion)}
  
  describe "#get_table_data promotion" do
    subject {results = DailySummaryAccount.get_table_data(promotion.id, "05/20/2013", "05/25/2013")[0].count}
    it {should == 1012}
  end
  
  describe "#get_table_data conversion" do
    subject {results = DailySummaryAccount.get_table_data(promotion.id, "05/20/2013", "05/25/2013")[1].count}
    it {should == 36}
  end
  
  describe "#get_table_data date range" do
    subject {results = DailySummaryAccount.get_table_data(promotion.id, "05/20/2013", "05/25/2013")[2].count}
    it {should == 6}
  end
end
