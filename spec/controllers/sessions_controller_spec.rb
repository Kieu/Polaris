require 'spec_helper'

describe SessionsController do
  let!(:user) {FactoryGirl.create(:user_super)}
  let(:action_login) do
    post :create, session: {email: user.email, password: user.password}
  end

  describe "GET new" do
    before {get :new}
    subject {response}
    it {should render_template :new}
  end
  
  describe "POST create" do
    context "with valid login info" do
      describe "when user is blocked less than 5 minutes" do
        before do
          BlockLoginUser.create(user_id: user.id, login_fail_num: 3,
            block_at_time: 3.minutes.ago)
        end
        before {action_login}

        describe "don't let user login" do
          subject {session[:user_id]}
          it {should be_nil}
        end

        describe "render template new" do
          subject {response}
          it {should render_template :new}
        end
      end
      
      describe "when user is blocked more than 5 minutes or is not blocked" do
        before do
          BlockLoginUser.create(user_id: user.id, login_fail_num: 3,
            block_at_time: 6.minutes.ago)
        end
        before {action_login}

        describe "let user login" do
          subject {session[:user_id]}
          it {should eq user.id}
        end

        describe "redirect to clients_path" do
          subject {response}
          it {should redirect_to clients_path}
        end
      end
    end
    
    context "with invalid login info" do
      before do
        post :create, session: {email: user.email, password: "something"}
      end

      describe "don't let user login" do
        subject {session[:user_id]}
        it {should be_nil}
      end

      describe "render template new" do
        subject {response}
        it {should render_template :new}
      end
    end
  end

  describe "#signout" do
    before {session[:user_id] = user.id}
    before {post :signout}

    describe "destroy current session" do
      subject {session[:user_id]}
      it {should be_nil}
    end

    describe "redirect to root_path" do
      subject {response}
      it {should redirect_to root_path}
    end
  end
end
