require 'csv'

# export click logs data table from click logs screen to csv file
class ExportClickLogsData
  include Resque::Plugins::Status
  @queue = :click_logs

  def perform
    # make file name
    # file name fomat: {user_id}_export_click_logs_{current_date}.csv   Settings.EXPORT_CLICK_LOGS
    #options = Hash.new('user_id' => '1', 'promotion_id' => 764, 'media_category_id' => '','start_date' => '06/01/2013','end_date' => '06/21/2013', 'account_id' => '', 'show_error' => '1')
    promotion = Promotion.find(options['promotion_id'])
    file_name = promotion.roman_name + "_click_" +
    Time.now.strftime("%Y%m%d_%H%M%S") + Settings.file_type.CSV
    path_file = Settings.export_click_logs_path + file_name
    # initial this task
     background_job = BackgroundJob.find(options['bgj_id'])
     background_job.user_id = options['user_id']
     background_job.filename = file_name
     background_job.filepath = path_file
     background_job.type_view = Settings.type_view.DOWNLOAD
     background_job.status = Settings.job_status.PROCESSING
     background_job.save!
    
    # store csv file on server
    # path: doc/click_logs_export

    begin
      header_col = ["Click Time", "click ID", "Client name", "Promotion", "Media",
                    "Account name", "Campaign name", "Ad group", "Ad name", "Ad URL",
                     "link URL", "sesid", "Media session ID", "OS", "User_Agent",
                     "Remote IP", "Referer", "mark", "OK/NG", "Error code"]
      rows = ClickLog.get_logs(options['promotion_id'], options['media_category_id'],
        options['account_id'], options['start_date'], options['end_date'],
        options['show_error'])
      client_name = promotion.client.client_name
      medias = Media.select("id, media_name")
      accounts = Account.where(promotion_id: options['promotion_id']).
        select("id, account_name")
      display_groups = DisplayGroup.where(promotion_id: options['promotion_id']).
        select("id, name")
      display_ads = DisplayAd.where(promotion_id: options['promotion_id']).
        select("id, name")
      display_campaigns = DisplayCampaign.where(promotion_id: options['promotion_id']).
        select("id, name")
      
      I18n.locale = options['lang']
      
      os = { 1 => I18n.t("conversion.conversion_category.app.os.ios"), 2 => I18n.t("conversion.conversion_category.app.os.android"), 9 => I18n.t("conversion.conversion_category.app.os.other")}

      File.open(path_file, 'wb') do |bom|
        buffer = ['EF','BB','BF'].pack("H*H*H*")
        bom.seek(0,IO::SEEK_SET)
        bom.write(buffer)
      end
      
      CSV.open(path_file, "a+") do |csv|
        # make header for CSV file
        #csv << header_col
        csv << options['header_titles_csv']
        rows.each do |row|
          csv << [Time.at(row.click_utime).strftime("%Y/%m/%d %H:%M:%S"), row.id, client_name, promotion.promotion_name,
                  medias.find(row.media_id).media_name, accounts.find(row.account_id).account_name,
                  display_campaigns.find(row.campaign_id).name, display_groups.find(row.group_id).name,
                  display_ads.find(row.unit_id).name, row.request_uri, row.redirect_url,
                  row.session_id, row.media_session_id, os[row.device_category.to_i], row.user_agent.to_s, row.remote_ip, 
                  row.referrer, row.mark, row.state, I18n.t("log_error_messages")[row.error_code.to_i]]
        end
      end

      # success case
       volume = File.size(path_file)
       size_field = file_size_fomat volume
       background_job.size = size_field
       background_job.status = Settings.job_status.SUCCESS
       background_job.save!
    rescue
      # false case
       background_job.status = Settings.job_status.WRONG
       background_job.save!   
    ensure  
    end
  end
  private
  def file_size_fomat volume
    if volume < 1024
      return "#{volume}bytes"
    elsif volume == 1024
      return "1kB"
    elsif volume > 1024 && volume < (1024*1024)
      return (volume / 1024.0).round(2).to_s + "kB"
    else
      return (volume / (1024.0*1024.0)).round(2).to_s + "MB"
    end
  end
end
