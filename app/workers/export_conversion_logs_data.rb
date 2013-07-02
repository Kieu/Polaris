require 'csv'
# encoding: utf-8
# export conversion data table from conversion log screen to csv file
class ExportConversionLogsData
  include Resque::Plugins::Status
  @queue = :conversion_logs

  def perform
    # make file name
    # file name fomat: {user_id}_export_cv_logs_{current_date}.csv    Settings.EXPORT_CV_LOGS
    #options = Hash.new('promotion_id' => '1', 'user_id' => '1', 'conversion_id' => '', 'media_category_id' => '', 'account_id' => '', 'start_date' => '20130401', 'end_date' => '20130620', 'show_error' => '1')
    promotion = Promotion.find(options['promotion_id'])
    file_name = promotion.roman_name + "_CV_" +
    Time.now.strftime("%Y%m%d_%H%M%S") + Settings.file_type.CSV
    path_file = Settings.export_conversion_logs_path + file_name
    if File.exist?(path_file)
      return
    end
    # initial this task
     background_job = BackgroundJob.find(options['bgj_id'])
     background_job.user_id = options['user_id']
     background_job.filename = file_name
     background_job.filepath = path_file
     background_job.type_view = Settings.type_view.DOWNLOAD
     background_job.status = Settings.job_status.PROCESSING
     background_job.save!
#     
    # store csv file on server
    # path: doc/conversion_logs_export
    I18n.locale = options['lang']
    begin
      header_col = ["CV date time", "CV name", "CV category", "Tracking type",
                    "CV type", "Log ID", "Starting log ID", "Media approval",
                    "Client name", "Promotion", "Media", "Account", "Campaign",
                    "Ad group", "Ad name", "Link URL", "Click date time",
                    "Influx original", "sales", "volume", "Other", "verify",
                    "SUID", "sesid", "OS", "Repeat", "OK/NG", "User_Agent",
                    "Remote IP", "Referrer", "Media session ID", "mark",
                    "Reception log", "Send log", "Send date time", "Error message"]
      rows = ConversionLog.get_logs(options['promotion_id'], options['conversion_id'],
        options['media_category_id'], options['account_id'], options['start_date'],
        options['end_date'],options['show_error'] )
      
      
      medias = Media.select("id, media_name")
      medias_list = Hash.new 
      medias.each do | media |
        medias_list.store(media.id, media.media_name)
      end
      client_name = promotion.client.client_name
      conversions = Conversion.where(promotion_id: options['promotion_id']).select('id, conversion_name')
      conversions_list = Hash.new
      conversions.each do | conversion |
        conversions_list.store(conversion.id, conversion.conversion_name)
      end
      accounts = Account.where(promotion_id: options['promotion_id']).
        select("id, account_name")
      accounts_list = Hash.new
      accounts.each do | account |
        accounts_list.store(account.id, account.account_name)
      end
      display_groups = DisplayGroup.where(promotion_id: options['promotion_id']).
        select("id, name")
      display_groups_list = Hash.new
      display_groups.each do | group |
        display_groups_list.store(group.id, group.name)
      end
      display_ads = DisplayAd.where(promotion_id: options['promotion_id']).
        select("id, name")
      display_ads_list = Hash.new
      display_ads.each do | ads |
        display_ads_list.store(ads.id, ads.name)
      end  
      display_campaigns = DisplayCampaign.where(promotion_id: options['promotion_id']).
        select("id, name")
      display_campaigns_list = Hash.new
      display_campaigns.each do | campaign |
        display_campaigns_list.store(campaign.id, campaign.name)
      end  
      os = { 1 => I18n.t("conversion.conversion_category.app.os.ios"), 2 => I18n.t("conversion.conversion_category.app.os.android"), 9 => I18n.t("conversion.conversion_category.app.os.other")}
      conversion_categories = [I18n.t("conversion.conversion_category.web"), I18n.t("conversion.conversion_category.app.label"), I18n.t("conversion.conversion_category.combination")]
      
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
          if row.conversion_category && row.conversion_category.to_i > 0
            conversion_category = conversion_categories[row.conversion_category.to_i-1]
          else
            conversion_category = ''
          end
          if (row.group_id && row.group_id.to_i > 0)
            display_group_name = display_groups_list[row.group_id.to_i]
          else
            display_group_name = ''
          end
          if (row.campaign_id && row.campaign_id.to_i)
            display_campaign_name = display_campaigns_list[row.campaign_id.to_i]
          else
            display_campaign_name = ''
          end
          if row.media_id && row.media_id.to_i > 0
            media_name = medias_list[row.media_id.to_i]
          else
            media_name = ''
          end
          if row.unit_id && row.unit_id.to_i > 0
            display_ads_name = display_ads_list[row.unit_id.to_i]
          else
            display_ads_name = ''
          end
          if row.click_utime
            click_utime = Time.at(row.click_utime).strftime("%Y/%m/%d %H:%M:%S")
          else
            click_utime = ''
          end
          if row.send_utime
            send_utime = Time.at(row.send_utime).strftime("%Y/%m/%d %H:%M:%S")
          else
            send_utime = ''
          end
          csv << [Time.at(row.conversion_utime).strftime("%Y/%m/%d %H:%M:%S"), conversions_list[row.conversion_id],
            conversion_category,
            I18n.t("log_track_type")[row.track_type.to_i-1], I18n.t("log_repeat_flg")[row.repeat_flg.to_i],
            row.id, row.parent_conversion_id, row.approval_status, client_name,
            promotion.promotion_name, media_name,
            accounts_list[row.account_id], display_campaign_name,
            display_group_name, display_ads_name,
            row.redirect_url, click_utime, row.click_referrer, row.sales,
            row.profit, row.volume, row.others, row.verify, row.suid,row.session_id,
            os[row.device_category.to_i], row.repeat_processed_flg, row.log_state,
            row.user_agent, row.remote_ip, row.referrer, row.media_session_id,
            row.mark, row.request_uri, row.send_url, send_utime, I18n.t("log_cv_error_messages")[row.error_code.to_i]]
        end
      end
      #success case
      
       volume = File.size(path_file)
       size_field = file_size_fomat volume
       background_job.size = size_field
       background_job.breadcrumb = options['breadcrumb']
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
