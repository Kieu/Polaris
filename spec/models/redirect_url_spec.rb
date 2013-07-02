require 'spec_helper'

describe RedirectUrl do
  let(:redirect_information) {FactoryGirl.create(:redirect_information)}
  let(:redirect_url) {FactoryGirl.create(:redirect_url, mpv: redirect_information.mpv)}
  let(:promotion) {FactoryGirl.create(:promotion)}
  let(:account){ FactoryGirl.create(:account)}
  let(:media){ FactoryGirl.create(:media)}

  subject {redirect_url}

  it {should respond_to(:mpv)}
  it {should respond_to(:url)}
  it {should respond_to(:rate)}
  it {should respond_to(:name)}
  it {should be_valid}
  
  describe "get_url_data index" do
    subject{RedirectUrl.get_url_data promotion.id, account.id, media.id, 1, 10, "2013/05/01", "2013/05/02", type = 'index'}
    it {should == [[], [{"totalCount"=>0}]]}
  end
  
  describe "get_url_data index" do
    subject{RedirectUrl.get_url_data promotion.id, account.id, media.id, 1, 10, "2013/05/01", "2013/05/02", type = 'download'}
    it {should == [[], [{"totalCount"=>0}]]}
  end
end
