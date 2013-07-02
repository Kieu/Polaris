require 'spec_helper'

describe UrlSettingsController do
  let!(:user_super) {FactoryGirl.create(:user_super)}
  let!(:user_client) {FactoryGirl.create(:user_client)}
  let!(:client) {FactoryGirl.create(:client)}
  let!(:promotion) {FactoryGirl.create(:promotion, client_id: client.id)}
  let!(:media) {FactoryGirl.create(:media)}
  let!(:account) {FactoryGirl.create(:account, promotion_id: promotion.id,
                                     media_id: media.id)}
 
  let(:action_index) {get :index, promotion_id: promotion.id,
    account_id: account.id}
# let(:download_template) {get :download_template, promotion_id: promotion.id,
#   account_id: account.id}
# let(:download_csv) {post :download_csv}

  context "when user is not logged in" do
    describe "GET index" do
      before {action_index}
      subject {response}
      it {should redirect_to signin_path}
    end
    
#   describe "GET download_template" do
#     before {download_template}
#     subject {response}
#     it {should redirect_to signin_path}
#   end

#   describe "POST download_csv" do
#     before {download_csv}
#     subject {response}
#     it {should redirect_to signin_path}
#   end
  end

  context "when user logged in" do
    context "with role client" do
      before {session[:user_id] = user_client.id}

      describe "GET index" do
        before {action_index}
        subject {response}
        it {should redirect_to promotions_path}
      end

#     describe "GET download_template" do
#       before {download_template}
#       subject {response}
#       it {should redirect_to promotions_path}
#     end

#     describe "POST download_csv" do
#       before {download_csv}
#       subject {response}
#       it {should redirect_to promotions_path}
#     end
    end

    context "with role super or agency" do
      before {session[:user_id] = user_super.id}

      describe "GET index" do
        before {action_index}
        subject {response}
        it {should render_template :index}
      end

#     describe "GET download_template" do
#       before {download_template}
#       subject {response}
#       it {should == "OK"}
#     end

#     describe "POST download_csv" do
#       before {download_csv}
#       subject {response}
#       it {should == "OK"}
#     end
    end
  end
end
