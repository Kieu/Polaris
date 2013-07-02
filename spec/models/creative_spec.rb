require 'spec_helper'

describe Creative do
  let(:creative) {FactoryGirl.create(:creative)}

  subject {creative}

  it {should respond_to(:ad_id)}
  it {should respond_to(:creative_name)}
  it {should respond_to(:image)}
  it {should be_valid}
end
