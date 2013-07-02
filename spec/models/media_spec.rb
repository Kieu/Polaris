require 'spec_helper'

describe Media do
  let!(:media) {FactoryGirl.create(:media)}

  subject {media}

  it {should respond_to(:media_name)}
  it {should respond_to(:media_category_id)}
  it {should respond_to(:del_flg)}
  it {should be_valid}
  
  describe "#get_media_list" do
    subject {Media.get_media_list.count}
    it {should == 3}
  end

end
