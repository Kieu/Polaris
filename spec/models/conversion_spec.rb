require 'spec_helper'

describe Conversion do
  let(:client) {FactoryGirl.create(:client)}
  let(:promotion) {FactoryGirl.create(:promotion, client_id: client.id)}
  let(:cv_web) {FactoryGirl.create(:cv_web, promotion_id: promotion.id)}
  let(:cv_app_install) {FactoryGirl.create(:cv_app_install, promotion_id: promotion.id)}
  let(:cv_app_action) {FactoryGirl.create(:cv_app_action, promotion_id: promotion.id)}

  context "App Install" do
    subject {cv_app_install}

    it {should respond_to(:conversion_name)}
    it {should respond_to(:roman_name)}
    it {should respond_to(:conversion_category)}
    it {should respond_to(:track_type)}
    it {should respond_to(:os)}
    it {should respond_to(:conversion_mode)}
    it {should respond_to(:duplicate)}
    it {should respond_to(:track_method)}
    it {should respond_to(:url)}
    it {should respond_to(:facebook_app_id)}
    it {should respond_to(:unique_def)}
    it {should respond_to(:judging)}
    it {should respond_to(:sale_unit_price)}
    it {should respond_to(:reward_form)}

    it {should be_valid}

    context "should be invalid" do
      describe "when conversion name is blank" do
        before {cv_app_install.conversion_name = " "}
        it {should be_invalid}
      end

      describe "when roman name is blank" do
        before {cv_app_install.roman_name = " "}
        it {should be_invalid}
      end

      describe "when conversion category is blank" do
        before {cv_app_install.conversion_category = " "}
        it {should be_invalid}
      end

      describe "when track type is blank" do
        before {cv_app_install.track_type = " "}
        it {should be_invalid}
      end

      describe "when os is blank" do
        before {cv_app_install.os = " "}
        it {should be_invalid}
      end

      describe "when conversion mode is blank" do
        before {cv_app_install.conversion_mode = " "}
        it {should be_invalid}
      end

      describe "when duplicate is blank" do
        before {cv_app_install.duplicate = " "}
        it {should be_invalid}
      end

      describe "when track method is blank" do
        before {cv_app_install.track_method = " "}
        it {should be_invalid}
      end

      describe "when url is blank" do
        before {cv_app_install.url = " "}
        it {should be_invalid}
      end

      describe "when facebook app id is blank" do
        before {cv_app_install.facebook_app_id = " "}
        it {should be_invalid}
      end

      describe "when unique def is blank" do
        before {cv_app_install.unique_def = " "}
        it {should be_invalid}
      end

      describe "when sale unit price is not a number" do
        before {cv_app_install.sale_unit_price = "abc"}
        it {should be_invalid}
      end
    end
  end

  context "Web" do
    subject {cv_web}

    it {should respond_to(:start_point)}

    it {should be_valid}

    context "should be invalid" do
      describe "when start point is blank" do
        before {cv_web.start_point = " "}
        it {should be_invalid}
      end
    end
  end

  context "App Action" do
    subject {cv_app_action}

    it {should respond_to(:session_period)}

    it {should be_valid}

    context "should be invalid" do
      before {cv_app_action.session_period = " "}
      it {should be_invalid}
    end
  end

  describe "#create_mv" do
    before do
      cv_web.mv = ""
      cv_web.save
      cv_web.create_mv
    end

    subject {cv_web.mv}
    it {should_not be_blank}
  end
end
