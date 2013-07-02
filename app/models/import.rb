class Import < ActiveRecord::Base
  attr_accessible :csv

  has_attached_file :csv,
    path: ":rails_root/doc/url/import_url/:basename.:extension",
    url: "doc/url/import_url/:basename.:extension"

  validates_attachment :csv,
  :presence => {message: I18n.t('error_message_url_import.not_input')},
  :size => { :in => 0..300.megabytes, message: I18n.t('error_message_url_import.volumn_over')}

  def change_file_name(user_id)
    extension = File.extname(csv_file_name).downcase
    self.csv.instance_write(:file_name, "#{user_id}_import_url_#{Time.now.to_i}#{extension}")
  end
end
