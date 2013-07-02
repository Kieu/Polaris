require 'spec_helper'

describe RedirectInformation do
  let(:redirect_information) {FactoryGirl.create(:redirect_information)}

  subject {redirect_information}

  it {should respond_to(:mpv)}
  it {should respond_to(:client_id)}
  it {should respond_to(:promotion_id)}
  it {should respond_to(:media_category_id)}
  it {should respond_to(:media_id)}
  it {should respond_to(:account_id)}
  it {should respond_to(:campaign_id)}
  it {should respond_to(:group_id)}
  it {should respond_to(:unit_id)}
  it {should respond_to(:creative_id)}
  it {should respond_to(:click_unit)}
  it {should respond_to(:comment)}
  it {should respond_to(:del_flg)}
  it {should be_valid}
end
