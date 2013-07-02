require 'spec_helper'

describe AgenciesController do
  let!(:user_super) {FactoryGirl.create(:user_super)}
  let!(:user_agency) {FactoryGirl.create(:user_agency)}
  let!(:agency) {FactoryGirl.create(:agency)}

  let(:agency_name) {"agency_name"}
  let(:roman_name) {"roman_name"}
  let(:name_to_change) {"change"}

  let(:action_create) do
    post :create, agency: {agency_name: agency_name, roman_name: roman_name}
  end
  let(:action_update) do
    put :update, id: agency.id, agency: {agency_name: name_to_change}
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
      before {get :edit, id: agency.id}
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
        before {get :edit, id: agency.id}
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
          it "create new agency" do
            expect {action_create}.to change(Agency, :count).by 1
          end

          it "redirect to action new" do
            action_create
            response.should redirect_to action: :new
          end
        end

        context "with invalid params" do
          before {Agency.any_instance.stub(:valid?).and_return false}

          it "don't create new agency" do
            expect {action_create}.not_to change(Agency, :count)
          end

          it "render template new" do
            action_create
            response.should render_template :new
          end
        end
      end

      describe "GET edit" do
        before {get :edit, id: agency.id}
        subject {response}
        it {should render_template :edit}
      end

      describe "PUT update" do
        context "with valid params" do
          before {action_update}

          describe "update agency params" do
            subject {agency.reload.agency_name}
            it {should eq name_to_change}
          end

          describe "redirect to action index" do
            subject {response}
            it {should redirect_to action: :index}
          end
        end

        context "with invalid params" do
          before {Agency.any_instance.stub(:valid?).and_return false}
          before {action_update}

          describe "don't update agency params" do
            subject {agency.reload.agency_name}
            it {should_not eq name_to_change}
          end

          describe "render template edit" do
            subject {response}
            it {should render_template :edit}
          end
        end
        describe "POST get_agencies_list" do
        context "post get_agencies_list" do
          agencies = Agency.order_by_roman_name.page(1).per(10)
          it "render format :json" do
            post :get_agencies_list, page: 1, rp: 10, format: :json
            JSON.parse(response.body)["rows"].count.should eq agencies.length
          end
        end
      end
      end
    end
  end
end
