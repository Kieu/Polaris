require 'spec_helper'

describe User do
  let!(:user) {FactoryGirl.create(:user_super)}
  let!(:user_agency) {FactoryGirl.create(:user_agency)}
  let!(:user_client) {FactoryGirl.create(:user_client)}
  it {should respond_to(:username)}
  it {should respond_to(:roman_name)}
  it {should respond_to(:email)}
  it {should respond_to(:role_id)}
  it {should respond_to(:company_id)}
  it {should respond_to(:password_flg)}
    
  describe "when username is not present" do
    before {user.username = " "}
    it {should_not be_valid}
  end
  
  describe "when username is already taken" do
    before do
      user_with_same_name = user.dup
      user_with_same_name.email = "test@test.com"
      user_with_same_name.roman_name = "test"
      user_with_same_name.save
    end
    it {should_not be_valid}
  end
    
  describe "when roman name is not present" do
    before { user.roman_name = " " }
    it { should_not be_valid }
  end
    
  describe "when email is not present" do
    before { user.email = " " }
    it { should_not be_valid }
  end
    
  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
        foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        user.email = invalid_address
        user.should_not be_valid
      end      
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        user.email = valid_address
        user.should be_valid
      end      
    end
  end
    
  describe "when email address is already taken" do
    before do
      user_with_same_email = user.dup
      user_with_same_email.email = user.email.upcase
      user_with_same_email.save
    end
  
    it { should_not be_valid }
  end
  
  describe "valid attribute" do
    subject {user.valid_attribute?(:email)}
    it {should == true}
  end
  
  describe "update_login_fail" do
    before do
      BlockLoginUser.create(user_id: user.id, login_fail_num: 1)
      user.update_login_fail
    end
    subject {user.block_login_user}
    it {should_not nil}
  end
  
  describe "update_login_fail with none block" do
    subject {user.update_login_fail}
    it {should == BlockLoginUser.last}
  end
  
  describe "#can_login?" do
    context "when user can login" do
      it "should return true value" do
        user.can_login?.should eq(true)
      end
    end
    context "when user has been blocked" do
      context "within 5 minutes" do
        before do
          block = BlockLoginUser.new(login_fail_num: 3,
            block_at_time: Time.now)
          user.block_login_user = block
        end
        it "should return false value" do
          user.can_login?.should eq(false)
        end
      end
      context "not within 5 minutes" do
        before do
          block = BlockLoginUser.create(user_id: user.id, login_fail_num: 3,
            block_at_time: 6.minutes.ago)
          user.block_login_user = block
        end
        it "should remove login_fail_num to 0 value" do
          user.can_login?
          user.block_login_user.login_fail_num.should eq(0)
          user.block_login_user.block_at_time.should eq(nil)
        end
      end
    end
  end

  describe "#toggle_enabled" do
    let!(:client) {FactoryGirl.create(:client)}
    let!(:client_user) {FactoryGirl.create(:client_user,
      client_id: client.id, user_id: user.id)}
    before {user.toggle_enabled}

    describe "set status to deactive" do
      subject {user.reload.status}
      it {should eq Settings.user.deactive}
    end

    describe "set client_user status to deleted" do
      subject {client_user.reload.del_flg}
      it {should eq Settings.client_user.deleted}
    end
  end
  
  describe "#super?" do
    subject {user.super?}
    it {should == true}
  end
  
  describe "#agency?" do
    subject {user_agency.agency?}
    it {should == true}
  end
  
  describe "#client?" do
    subject {user_client.client?}
    it {should == true}
  end
end
