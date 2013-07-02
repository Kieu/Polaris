require 'spec_helper'

describe ConversionPromotionLogsController do
  let(:user) {FactoryGirl.create(:user_super)}
  describe "GET index" do
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
      let(:conversion_logs) {ConversionLog.get_all_logs(1, 1, 10, "", "",
                                                  "", start_date, end_date, 0, "conversion_utime", "desc")}
      let(:start_date) {"03/25/2013"}
      let(:end_date) {"06/25/2013"}
      it "should be render_template :index" do
        action_index
        response.should render_template :index
      end
      it "should be render list conversion logs format :json" do
        post :get_conversion_logs_list, query: 1, page: 1, rp: 10, sv_id: "",
         media_category_id: "", account_id: "", start_date: start_date, end_date: end_date,
          ser: 0, sortname: "conversion_utime", sortorder: "desc", media_id: "", format: :json
        JSON.parse(response.body)["rows"].count.should eq conversion_logs.length
      end
    end
  end
  describe "POST change_accounts_list" do
    before {session[:user_id] = user.id}
    context "post change_accounts_list with params[:cid]" do
      list_accounts = Account.where(media_category_id: 1).where(promotion_id: 1).order(:roman_name).select("id")
      .select("CASE WHEN LENGTH(account_name) > #{Settings.MAX_JA_LENGTH_NAME}
                               THEN SUBSTRING(account_name, 1, #{Settings.MAX_JA_LENGTH_NAME})
                                ELSE  account_name END as account_name ")
      it "render format :json" do
        post :change_accounts_list, cid: 1, promotion_id: 1, format: :json
        response.body.should eq list_accounts.to_json
      end
    end
    context "post change_accounts_list without params[:cid]" do
      list_accounts = Account.where(promotion_id: 1).order(:roman_name).select("id")
      .select("CASE WHEN LENGTH(account_name) > #{Settings.MAX_JA_LENGTH_NAME}
                               THEN SUBSTRING(account_name, 1, #{Settings.MAX_JA_LENGTH_NAME})
                                ELSE  account_name END as account_name ")
      it "render format :json" do
        post :change_accounts_list, promotion_id: 1, format: :json
        response.body.should eq list_accounts.to_json
      end
    end
  end
end
