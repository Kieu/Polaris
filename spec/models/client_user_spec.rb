require 'spec_helper'

describe ClientUser do
  let(:client_user) {FactoryGirl.create(:client_user)}

  subject {client_user}

  it {should respond_to(:client_id)}
  it {should respond_to(:user_id)}
  it {should respond_to(:del_flg)}
  it {should be_valid}

  describe "#active?" do
    subject {client_user.active?}
    it {should eq true}
  end
end
