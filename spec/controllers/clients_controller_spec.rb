require 'spec_helper'

describe ClientsController do
  let!(:user_super) {FactoryGirl.create(:user_super)}
  let!(:user_client) {FactoryGirl.create(:user_client)}
  let!(:client) {FactoryGirl.create(:client)}

  let(:client_name) {"client01"}
  let(:roman_name) {"client01"}
  let(:tel) {"123456789"}
  let(:person_charge) {"person01"}
  let(:person_sale) {"person02"}
  let(:contract_flg) {0}
  let(:contract_type) {0}
  let(:name_to_change) {"change"}

  let(:action_create) do
    post :create, client: {client_name: client_name, roman_name: roman_name,
      tel: tel, person_charge: person_charge, person_sale: person_sale,
      contract_flg: contract_flg, contract_type: contract_type}
  end
  let(:action_update) do
    put :update, id: client.id, client: {client_name: name_to_change}
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
      before {get :edit, id: client.id}
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

      describe "GET index" do
        before {get :index}
        subject {response}
        it {should redirect_to promotions_path}
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
        before {get :edit, id: client.id}
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
          it "create new client" do
            expect {action_create}.to change(Client, :count).by 1
          end

          it "redirect to new action" do
            action_create
            response.should render_template js: "create"
          end
        end

        context "with invalid params" do
          before {Client.any_instance.stub(:valid?).and_return false}

          it "don't create new client" do
            expect {action_create}.not_to change(Client, :count)
          end

          it "render new action" do
            action_create
            response.should render_template js: "create"
          end
        end
      end

      describe "GET edit" do
        before {get :edit, id: client.id}
        subject {response}
        it {should render_template :edit}
      end

      describe "PUT update" do
        context "with valid params" do
          before {action_update}

          describe "update client params" do
            subject {client.reload.client_name}
            it {should eq name_to_change}
          end

          describe "redirect to action index" do
            subject {response}
            it {should render_template js: "update"}
          end
        end

        context "with invalid params" do
          before {Client.any_instance.stub(:valid?).and_return false}
          before {action_update}

          describe "don't update client params" do
            subject {client.reload.client_name}
            it {should_not eq name_to_change}
          end

          describe "render template edit" do
            subject {response}
            it {should render_template js: "update"}
          end
        end
      end
    end
  end
end
