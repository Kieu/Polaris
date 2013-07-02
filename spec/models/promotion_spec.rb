require 'spec_helper'

describe Promotion do
  let(:promotion) {FactoryGirl.create(:promotion)}
  subject {promotion}
  it {should respond_to(:promotion_name)}
  it {should respond_to(:roman_name)}
  it {should respond_to(:promotion_category_id)}
  it {should respond_to(:tracking_period)}

  context "must be valid" do
    it {should be_valid}
  end

  context "must be invalid" do
    describe "when promotion_name is blank" do
      before {promotion.promotion_name = " "}
      it {should_not be_valid}
    end

    describe "when roman_name is blank" do
      before {promotion.roman_name = " "}
      it {should_not be_valid}
    end

    describe "when promotion_category_id is blank" do
      before {promotion.promotion_category_id = " "}
      it {should_not be_valid}
    end

    describe "when tracking_period is blank" do
      before {promotion.tracking_period = " "}
      it {should_not be_valid}
    end
  end
  
  context "delete" do
    before {promotion.delete}
    subject {promotion.del_flg}
    it {should == Settings.promotion.deleted}
  end
  
  context "deleted?" do
    subject {promotion.deleted?}
    it {should == false}
  end
end
