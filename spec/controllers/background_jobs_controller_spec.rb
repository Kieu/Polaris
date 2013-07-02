require 'spec_helper'

describe BackgroundJobsController do
  let!(:user_super) {FactoryGirl.create(:user_super)}
  let!(:background_job) {FactoryGirl.create(:background_job, user_id: user_super.id)}
  
  context "when user don't login" do
    describe "GET download" do
      before {get :download}
      subject {response}
      it {should redirect_to signin_path}
    end
    
    describe "GET upload" do
      before {get :upload}
      subject {response}
      it {should redirect_to signin_path}
    end
    
    describe "GET index" do
      before {get :index}
      subject {response}
      it {should redirect_to signin_path}
    end
    
    describe "GET notification" do
      before {get :notification}
      subject {response}
      it {should redirect_to signin_path}
    end
    
    describe "GET inprogress" do
      before {get :inprogress}
      subject {response}
      it {should redirect_to signin_path}
    end
    
    describe "POST download_file" do
      before {post :download_file}
      subject {response}
      it {should redirect_to signin_path}
    end
    
    describe "POST kill_job" do
      before {post :kill_job}
      subject {response}
      it {should redirect_to signin_path}
    end
  end
  
  context "when user logged in" do
    
    before {session[:user_id] = user_super.id}
    
    describe "GET download" do
      before {get :download}
      subject {response}
      it {should render_template :new}
    end
    
    describe "GET upload" do
      before {get :upload}
      subject {response}
      it {should render_template :upload}
    end
    
    describe "GET index" do
      before {get :index}
      subject {response}
      it {should render_template :new}
    end
    
    describe "POST notification" do
      before {post :notification}
      subject {response}
      it {body.should == ""}
    end
    
    describe "GET inprogress" do
      before {get :inprogress}
      subject {response}
      it {should render_template :inprogress}
    end
    
    describe "get download_file" do
      before {get :download_file, id: background_job.id, format: :csv}
      it {controller.should_not_receive(:send_file)}
    end
    
    describe "POST kill_job" do
      before {post :kill_job, id: background_job.id}
      subject {response}
      it {body.should == ""}
    end
  end
end
