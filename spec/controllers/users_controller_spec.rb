require 'spec_helper'

describe UsersController do
# let!(:role_super) {FactoryGirl.create(:role_super)}
# let!(:role_client) {FactoryGirl.create(:role_client)}
# let!(:role_agency) {FactoryGirl.create(:role_agency)}
  let!(:user_super) {FactoryGirl.create(:user_super)}
  let!(:user_agency) {FactoryGirl.create(:user_agency)}
  let!(:user_client) {FactoryGirl.create(:user_client)}
  let!(:client) {FactoryGirl.create(:client)}
  let!(:agency) {FactoryGirl.create(:agency)}
  let!(:client_user) {FactoryGirl.create(:client_user,
    client_id: client.id, user_id: user_client.id)}

  let(:username) {"username"}
  let(:roman_name) {"roman_name"}
  let(:email) {"email@example.com"}
  let(:company_id) {client.id}
  let(:role_id) {Settings.role.CLIENT}
  let(:password_flg) {0}
  let(:name_to_change) {"change"}

  let(:action_create) do
    post :create, user: {username: username, roman_name: roman_name, email: email,
      company_id: company_id, role_id: role_id, password_flg: password_flg}
  end
  let(:action_update) do
    put :update, id: user_client.id, user: {username: name_to_change}
  end

  context "when user don't login" do
    describe "GET index" do
      before {get :index}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "GET new" do
      before {get :new}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "POST create" do
      before {action_create}
      subject {response}
      it {should redirect_to signin_path}
    end

    describe "GET edit" do
      before {get :edit, id: user_client.id}
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
    context "with role not super" do
      before {session[:user_id] = user_agency.id}

      describe "GET index" do
        before {get :index}
        subject {response}
        it {should redirect_to root_path}
      end

      describe "GET new" do
        before {get :new}
        subject {response}
        it {should redirect_to root_path}
      end

      describe "POST create" do
        before {action_create}
        subject {response}
        it {should redirect_to root_path}
      end

      describe "GET edit" do
        before {get :edit, id: user_client.id}
        subject {response}
        it {should redirect_to root_path}
      end

      describe "PUT update" do
        before {action_update}
        subject {response}
        it {should redirect_to root_path}
      end
    end

    context "with role super" do
      before {session[:user_id] = user_super.id}

      describe "GET index" do
        before {get :index}
        subject {response}
        it {should render_template :index}
      end

      describe "GET new" do
        before {get :new}
        subject {response}
        it {should render_template :new}
      end

      describe "POST create" do
        context "with valid params" do
          it "create new user" do
            expect {action_create}.to change(User, :count).by 1
          end

          it "create new client_user" do
            expect {action_create}.to change(ClientUser, :count).by 1
          end

          it "redirect to action new" do
            action_create
            response.should redirect_to action: :new
          end
        end

        context "with invalid params" do
          before {User.any_instance.stub(:valid?).and_return false}

          it "don't create new user" do
            expect {action_create}.not_to change(User, :count)
          end

          it "don't create new client_user" do
            expect {action_create}.not_to change(ClientUser, :count)
          end

          it "render template new" do
            action_create
            response.should render_template :new
          end
        end
      end

      describe "GET edit" do
        before {get :edit, id: user_client.id}
        subject {response}
        it {should render_template :edit}
      end

      describe "PUT update" do
        context "with valid params" do
          before {action_update}

          describe "update user params" do
            subject {user_client.reload.username}
            it {should eq name_to_change}
          end

          describe "redirect to action index" do
            subject {response}
            it {should redirect_to action: :index}
          end
        end

        context "with invalid params" do
          before {User.any_instance.stub(:valid?).and_return false}
          before {action_update}

          describe "don't update user params" do
            subject {user_client.reload.username}
            it {should_not eq name_to_change}
          end

          describe "render template edit" do
            subject {response}
            it {should render_template :edit}
          end
        end
      end
    end
  end
end
