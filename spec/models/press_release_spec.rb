require 'spec_helper'

describe PressRelease do
  let(:press_release) {FactoryGirl.create(:press_release)}

  subject {press_release}

  it {should respond_to(:content)}
  it {should respond_to(:release_time)}
  it {should be_valid}
end
