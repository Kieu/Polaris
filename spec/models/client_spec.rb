require 'spec_helper'

describe Client do
  let(:client){FactoryGirl.create(:client)}
  it { should respond_to(:client_name) }
  it { should respond_to(:roman_name) }
  it { should respond_to(:tel) }
  it { should respond_to(:contract_flg) }
  it { should respond_to(:contract_type) }
  it { should respond_to(:person_charge) }
  it { should respond_to(:person_sale) }

  context "client can be valid" do
    subject {FactoryGirl.create(:client)}
    it { should be_valid }
  end

  context "client can be invalid" do
    let(:client) {FactoryGirl.create(:client)}

    describe "when client_name is not present" do
      before { client.client_name = " " }
      it { should_not be_valid }
    end

    describe "when roman_name is not present" do
      before { client.roman_name = " " }
      it { should_not be_valid }
    end

    describe "when tel is not present" do
      before { client.tel = " " }
      it { should_not be_valid }
    end

    describe "when tel is not format" do
      invalid_tel = ["a1234567","12-1234567", "1234567890123456"]
      invalid_tel.each do |tel|
        before { client.tel = tel }
        it { should_not be_valid }
      end
    end

    describe "when contract_flg is not present" do
      before { client.contract_flg = " " }
      it { should_not be_valid }
    end

    describe "when contract_type is not present" do
      before { client.contract_type = " " }
      it { should_not be_valid }
    end

    describe "when person_charge is not present" do
      before { client.person_charge = " " }
      it { should_not be_valid }
    end

    describe "when person_sale is not present" do
      before { client.person_sale = " " }
      it { should_not be_valid }
    end

  end

  describe "#name_with_initial" do
    before {client.client_name = "a" * 50}
    subject {client.name_with_initial}
    it {should eq "a" * Settings.MAX_JA_LENGTH_NAME + "..."}
  end
end
