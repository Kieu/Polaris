require 'spec_helper'

describe ClickLogsController do
  describe "GET index" do
    let(:user) {FactoryGirl.create(:user_super)}
    let(:promotion) {FactoryGirl.create(:promotion)}
    let(:client) {FactoryGirl.create(:client)}
    let(:action_index) {get :index, promotion_id: promotion.id}
    context "when uesr don't login" do
      it "should redirect to signin_path" do
        action_index
        response.should redirect_to signin_path
      end
    end

    context "when user loged in" do
      before {session[:user_id] = user.id}
      let(:click_logs) {ClickLog.get_all_logs(1, 1, 10, "click_utime", "desc",
                             "", "", start_date, end_date, 0,)}
      let(:user) {FactoryGirl.create(:user_super)}
      let(:promotion) {FactoryGirl.create(:promotion)}
      let(:client) {FactoryGirl.create(:client)}
      let(:start_date) {"03/25/2013"}
      let(:end_date) {"06/25/2013"}
      it "should be render_template :index" do
        action_index
        response.should render_template :index
      end

      it "should be render list conversion logs format :json" do
        post :get_logs_list, query: 1, page: 1, rp: 10,sortname: "click_utime", sortorder: "desc",
         media_category_id: "", account_id: "", start_date: start_date, end_date: end_date,
          cser: 0, format: :json
        JSON.parse(response.body)["rows"].count.should eq click_logs.length
      end
    end
  end
end
