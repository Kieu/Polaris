require 'spec_helper'

describe ApplicationHelper do
  describe "short_en_name" do
    before {name = "a" * 50}
    subject {short_en_name(name)}
    it {should eq ("a" * Settings.MAX_EN_LENGTH_NAME + "...")}
  end

  describe "short_ja_name" do
    before {name = "a" * 50}
    subject {short_ja_name(name)}
    it {should eq ("a" * Settings.MAX_JA_LENGTH_NAME + "...")}
  end

  describe "full_title" do
    describe "without page title" do
      subject {full_title("")}
      it {should eq "Polaris"}
    end

    describe "with page title" do
      subject {full_title("page_title")}
      it {should eq "Polaris | page_title"}
    end
  end
end
