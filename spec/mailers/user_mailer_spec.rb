require 'spec_helper'
 
describe UserMailer do
  describe 'Send password' do
    let!(:user_super) {FactoryGirl.create(:user_super)}
    let(:mail) { UserMailer.send_password(user_super, "123456") }
 
    #ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should == Settings.mailer.send_password_subject
    end
 
    #ensure that the receiver is correct
  end
end