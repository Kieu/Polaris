require 'spec_helper'

describe Account do
  let(:account){ FactoryGirl.create(:account)}
  it {should respond_to(:promotion_id)}
  it {should respond_to(:media_id)}
  it {should respond_to(:sync_account_id)}
  it {should respond_to(:sync_account_pw)}
  it {should respond_to(:account_name)}
  it {should respond_to(:roman_name)}
  it {should respond_to(:sync_flg)}
  it {should respond_to(:margin)}
  it {should respond_to(:create_user_id)}
  it {should respond_to(:update_user_id)}

  context "account can be valid" do
    subject {FactoryGirl.create(:account)}
    it {should be_valid}
  end

  context "account can be invalid" do
    let(:account) {FactoryGirl.create(:account)}

    describe "when account name is not present" do
      before {account.account_name = " "}
      it {should_not be_valid}
    end

    describe "when romanji name is not present" do
      before {account.roman_name = " "}
      it {should_not be_valid}
    end

    describe "when Synchronize account is not present" do
      before {account.sync_account_id = " "}
      it {should_not be_valid}
    end

    describe "when Synchronize account password is not present" do
      before {account.sync_account_pw = " "}
      it {should_not be_valid}
    end
    
    describe "when cost is not present" do
      before {account.margin = " "}
      it {should_not be_valid}
    end
  end
end
