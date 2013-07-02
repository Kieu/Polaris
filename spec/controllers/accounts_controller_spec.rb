require 'spec_helper'

describe AccountsController do
  let!(:user_super) {FactoryGirl.create(:user_super)}
  let!(:user_client) {FactoryGirl.create(:user_client)}
  let!(:client) {FactoryGirl.create(:client)}
  let!(:promotion) {FactoryGirl.create(:promotion, client_id: client.id)}
  let!(:account) {FactoryGirl.create(:account, promotion_id: promotion.id)}

  let(:promotion_id) {promotion.id}
  let(:media_id) {1}
  let(:account_name) {"account01"}
  let(:roman_name) {"roman_account01"}
  let(:sync_flg) {1}
  let(:sync_account_id) {"sync_account01"}
  let(:sync_account_pw) {"123123"}
  let(:margin) {100}
  let(:name_to_change) {"name_change"}
  
  let(:action_create) do
    post :create, promotion_id: promotion.id, account: {promotion_id: promotion_id, media_id: media_id,
     account_name: account_name, roman_name: roman_name, sync_flg: sync_flg,
     sync_account_id: sync_account_id, sync_account_pw: sync_account_pw, margin: margin}
  end
  let(:action_update) do
    put :update, id: account.id, promotion_id: promotion.id, account: {account_name: name_to_change}
  end
  let(:change_medias_list) do
    post :change_medias_list, media_category_id: 1, :format => :json
  end
  context "when user don't login" do
    describe "GET new" do
      before {get :new, promotion_id: promotion_id}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "POST create" do
      before {action_create}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "GET edit " do
      before {get :edit, id: account.id, promotion_id: promotion.id}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "PUT update" do
      before {action_update}
      subject {response}
      it {should redirect_to signin_path}
    end
  end

  context "when user logged in" do
    context "with role client" do
      before {session[:user_id] = user_client.id}

      describe "GET new" do
        before {get :new, promotion_id: promotion_id}
        subject {response}
        it {should redirect_to promotions_path}
      end

      describe "POST create" do
        before {action_create}
        subject {response}
        it {should redirect_to promotions_path}
      end

      describe "GET edit " do
        before {get :edit, id: account.id, promotion_id: promotion.id}
        subject {response}
        it {should redirect_to promotions_path}
      end

      describe "PUT update" do
        before {action_update}
        subject {response}
        it {should redirect_to promotions_path}
      end
    end

    context "with role super" do
      before {session[:user_id] = user_super.id}  


      describe "GET new" do
        before {get :new, promotion_id: promotion.id}
        subject {response}
        it {should render_template :new}
      end

      describe "POST create" do
        context "with valid params" do
          it "create new account" do
            expect {action_create}.to change(Account, :count).by 1
          end

          it "redirect to promotions path" do
            action_create
            response.should redirect_to promotions_path(promotion_id: promotion_id, client_id: promotion.client_id)
          end
        end

        context "with invalid params" do
          before {Account.any_instance.stub(:valid?).and_return false}
          
          it "don't create new account" do
            expect {action_create}.not_to change(Account, :count)
          end

          it "render template new" do
            action_create
            response.should render_template :new
          end
        end
      end

      describe "GET edit" do
        before {get :edit, id: account.id, promotion_id: promotion.id}
        subject {response}
        it {should render_template :edit}
      end

      describe "PUT update" do
        
        context "with valid params" do
          it "edit account infomation" do
            action_update
            account.reload.account_name.should eq name_to_change
          end

          it "redirect to promotions path" do
            action_update
            response.should redirect_to promotions_path(promotion_id: promotion.id, client_id: promotion.client_id )
          end
        end

        context "with invalid params" do
          before {Account.any_instance.stub(:valid?).and_return false}
          before {action_update}
          it "can't update account infomation" do
            action_update
            account.reload.account_name.should_not eq name_to_change
          end

          it "redirect to promotions path" do
            response.should render_template :edit
          end
        end
      end

      describe "POST change_media_list" do
        context "post change_medias_list" do
          #let(:format) {:json}
          list_medias = Media.active.where(media_category_id: 1)
          it "render format :json" do
            post :change_medias_list, cid: 1, format: :json
            response.body.should eq list_medias.to_json
          end
        end
      end
    end
  end
end
