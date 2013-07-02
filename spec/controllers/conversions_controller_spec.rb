require "spec_helper"

describe ConversionsController do
  let!(:user_super) {FactoryGirl.create(:user_super)}
  let!(:user_client) {FactoryGirl.create(:user_client)}
  let!(:client) {FactoryGirl.create(:client)}
  let!(:promotion) {FactoryGirl.create(:promotion, client_id: client.id)}
  let!(:conversion) {FactoryGirl.create(:cv_app_install, promotion_id: promotion.id)}

  let(:conversion_name) {"conversion_test"}
  let(:roman_name) {"conversion_test"}
  let(:conversion_category) {"2"}
  let(:track_type) {"1"}
  let(:os) {"1"}
  let(:conversion_mode) {"0"}
  let(:duplicate) {"1"}
  let(:track_method) {"4"}
  let(:url) {"https://testing.com"}
  let(:facebook_app_id) {"123456789"}
  let(:unique_def) {"1"}
  let(:judging) {"1"}
  let(:sale_unit_price) {100}
  let(:reward_form) {"1"}
  let(:name_to_change) {"change"}

  let(:action_index) do
    get :index, promotion_id: promotion.id
  end
  let(:action_new) do
    get :new, promotion_id: promotion.id
  end
  let(:action_create) do
    post :create, conversion: {conversion_name: conversion_name,
      roman_name: roman_name, conversion_category: conversion_category,
      track_type: track_type, os: os, conversion_mode: conversion_mode,
      duplicate: duplicate, track_method: track_method, url: url,
      facebook_app_id: facebook_app_id, unique_def: unique_def, judging: judging,
      sale_unit_price: sale_unit_price, reward_form: reward_form},
      promotion_id: promotion.id
  end
  let(:action_edit) do
    get :edit, id: conversion.id, promotion_id: conversion.promotion_id
  end
  let(:action_update) do
    put :update, id: conversion.id, promotion_id: conversion.promotion_id,
      conversion: {conversion_name: name_to_change}
  end
  let(:action_get_tag) do
    get :get_tag, id: conversion.id, promotion_id: conversion.promotion_id
  end

  context "when user is not logged in" do
    describe "GET index" do
      before {action_index}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "GET new" do
      before {action_new}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "POST create" do
      before {action_create}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "GET edit" do
      before {action_edit}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "PUT update" do
      before {action_update}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "GET get_tag" do
      before {action_get_tag}
      subject {response}
      it {should redirect_to signin_path}
    end
  end

  context "when user is logged in" do
    context "with role client" do
      before {session[:user_id] = user_client.id}

      describe "GET index" do
        before {action_index}
        subject {response}
        it {should redirect_to promotions_path}
      end

      describe "GET new" do
        before {action_new}
        subject {response}
        it {should redirect_to promotions_path}
      end

      describe "POST create" do
        before {action_create}
        subject {response}
        it {should redirect_to promotions_path}
      end

      describe "GET edit" do
        before {action_edit}
        subject {response}
        it {should redirect_to promotions_path}
      end

      describe "PUT update" do
        before {action_update}
        subject {response}
        it {should redirect_to promotions_path}
      end

      describe "GET get_tag" do
        before {action_get_tag}
        subject {response}
        it {should redirect_to promotions_path}
      end
    end

    context "with role super or agency" do
      before {session[:user_id] = user_super.id}

      describe "GET index" do
        before {action_index}
        subject {response}
        it {should render_template :index}
      end

      describe "GET new" do
        before {action_new}
        subject {response}
        it {should render_template :new}
      end

      describe "POST create" do
        context "with valid params" do
          it "create new conversion" do
            expect {action_create}.to change(Conversion, :count).by 1
          end

          it "redirect to action index" do
            action_create
            response.should redirect_to action: :index, promotion_id: promotion.id
          end
        end

        context "with invalid params" do
          before {Conversion.any_instance.stub(:valid?).and_return false}

          it "don't create new conversion" do
            expect {action_create}.not_to change(Conversion, :count)
          end

          it "render template new" do
            action_create
            response.should render_template :new
          end
        end
      end

      describe "GET edit" do
        before {action_edit}
        subject {response}
        it {should render_template :edit}
      end

      describe "PUT update" do
        context "with valid params" do
          before {action_update}

          describe "update conversion params" do
            subject {conversion.reload.conversion_name}
            it {should eq name_to_change}
          end

          describe "redirect to action index" do
            subject {response}
            it {should redirect_to action: :index, promotion_id: promotion.id}
          end
        end

        context "with invalid params" do
          before do
            Conversion.any_instance.stub(:valid?).and_return false
            action_update
          end

          describe "don't update conversion params" do
            subject {conversion.reload.conversion_name}
            it {should_not eq name_to_change}
          end

          describe "render template edit" do
            subject {response}
            it {should render_template :edit}
          end
        end
      end

      describe "GET get_tag" do
        before {action_get_tag}
        subject {response}
        it {should render_template :get_tag}
      end
    end
  end
end
