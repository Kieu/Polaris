require 'spec_helper'

describe Import do
  import = Import.new({csv_file_name: "test.csv", csv_content_type: "text/csv",
                      csv_file_size: 800}, without_protection: true)
  let!(:old_name) {import.csv_file_name}
  let!(:user) {FactoryGirl.create(:user_super)}

  subject {import}

  it {should respond_to(:csv_file_name)}
  it {should respond_to(:csv_content_type)}
  it {should respond_to(:csv_file_size)}
  it {should be_valid}

  describe "#change_file_name" do
    before {import.change_file_name(user.id)}
    subject {import.csv_file_name}
    it {should_not eq old_name}
  end
end
