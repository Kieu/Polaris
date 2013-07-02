require "resque"
class ConversionPromotionLogsController < ApplicationController
  before_filter :signed_in_user
  before_filter :set_cookies
  include ActionView::Helpers::NumberHelper
  def index
    @start_date = params[:start_date].present? ? params[:start_date] :
        Date.yesterday.at_beginning_of_month.strftime(I18n.t("time_format"))
    @end_date = params[:end_date].present? ? params[:end_date] :
        Date.yesterday.strftime(I18n.t("time_format"))
    @promotion_id = params[:promotion_id]
    @promotion = Promotion.find(@promotion_id)
    if current_user.client?
      @client_id = current_user.company_id
    else
      @client_id =@promotion.client_id
    end
    @promotions = @client_id.blank? ? Array.new :
        Promotion.active.get_by_client(@client_id).order_by_roman_name
    @array_conversion = Conversion.where(promotion_id: @promotion.id).order(:roman_name).select("id")
    .select("CASE WHEN LENGTH(conversion_name) > #{Settings.MAX_JA_LENGTH_NAME}
                                   THEN SUBSTRING(conversion_name, 1, #{Settings.MAX_JA_LENGTH_NAME})
                                    ELSE  conversion_name END as conversion_name ")
    @array_account = Account.where(promotion_id: @promotion.id).order(:roman_name).select("id")
    .select("CASE WHEN LENGTH(account_name) > #{Settings.MAX_JA_LENGTH_NAME}
                                   THEN SUBSTRING(account_name, 1, #{Settings.MAX_JA_LENGTH_NAME})
                                    ELSE  account_name END as account_name ")
  end

  def get_conversion_logs_list
    start_date = params[:start_date].strip
    end_date = params[:end_date].strip
    promotion_id = params[:query]
    @conversion_logs = ConversionLog.get_all_logs(promotion_id, params[:page], params[:rp], params[:cv_id], params[:media_category_id],
                                                  params[:account_id], start_date, end_date, cookies[:ser], params[:sortname], params[:sortorder])
    if @conversion_logs
      rows = get_rows(@conversion_logs)
    else
      rows = Array.new
    end
    count = ConversionLog.get_count(promotion_id, params[:cv_id], params[:media_category_id], params[:account_id],
                                    start_date, end_date, cookies[:ser])
    render json: {page: params[:page], total: count, rows: rows}
  end


  def download_csv
    background_job = BackgroundJob.create
    promotion = Promotion.find(params[:promotion_id].to_i)
    header_titles_csv = [I18n.t('export_conversion_logs.cv_date_time'), I18n.t('export_conversion_logs.cv_name'), I18n.t('export_conversion_logs.cv_category'), I18n.t('export_conversion_logs.tracking_type'), I18n.t('export_conversion_logs.cv_type'), I18n.t('export_conversion_logs.log_id'),
                         I18n.t('export_conversion_logs.starting_log_id'), I18n.t('export_conversion_logs.media_approval'), I18n.t('export_conversion_logs.click_name'), I18n.t('export_conversion_logs.promotion'), I18n.t('export_conversion_logs.media'), I18n.t('export_conversion_logs.account'),
                         I18n.t('export_conversion_logs.campaign'), I18n.t('export_conversion_logs.ad_group'), I18n.t('export_conversion_logs.ad_name'), I18n.t('export_conversion_logs.click_utime'), I18n.t('export_conversion_logs.click_date_time'), I18n.t('export_conversion_logs.influx_original'),
                         I18n.t('export_conversion_logs.sales'),I18n.t('export_conversion_logs.profit'), I18n.t('export_conversion_logs.volume'), I18n.t('export_conversion_logs.other'), I18n.t('export_conversion_logs.verify'), I18n.t('export_conversion_logs.suid'), I18n.t('export_conversion_logs.sesid'),
                         I18n.t('export_conversion_logs.os'), I18n.t('export_conversion_logs.repeat'), I18n.t('export_conversion_logs.log_state'), I18n.t('export_conversion_logs.user_agent'), I18n.t('export_conversion_logs.remote_ip'), I18n.t('export_conversion_logs.referrer'),
                         I18n.t('export_conversion_logs.media_session_id'), I18n.t('export_conversion_logs.mark'), I18n.t('export_conversion_logs.reception_log'), I18n.t('export_conversion_logs.send_log'), I18n.t('export_conversion_logs.send_date_time'), I18n.t('export_conversion_logs.error_message')]
    
    breadcrumb = "#{promotion.client.client_name} > #{promotion.promotion_name} > CV Logs"
    start_date = Date.strptime(params[:start_date].strip, I18n.t("time_format")).strftime("%Y%m%d")
    end_date = Date.strptime(params[:end_date].strip, I18n.t("time_format")).strftime("%Y%m%d")
    job_id = ExportConversionLogsData.create(user_id: current_user.id,
                                             promotion_id: params[:promotion_id].to_i,
                                             conversion_id: params[:conversion_id],
                                             media_category_id: params[:media_category_id],
                                             account_id: params[:account_id], start_date: start_date,
                                             end_date: end_date, show_error: cookies[:ser],
                                             breadcrumb: breadcrumb,
                                             header_titles_csv: header_titles_csv,
                                             lang: cookies[:locale],
                                             bgj_id: background_job.id)
    background_job.user_id = current_user.id
    background_job.breadcrumb = breadcrumb
    background_job.job_id = job_id
    background_job.type_view = Settings.type_view.DOWNLOAD
    background_job.status = Settings.job_status.PROCESSING
    background_job.save!
    render text: "processing"
  end

  def get_rows conversion_logs
    medias = Media.select("id, media_name")
    medias_list = Hash.new 
    medias.each do | media |
      medias_list.store(media.id, media.media_name)
    end
    
    display_groups = DisplayGroup.where(promotion_id: params[:query]).select("id, name")
    display_groups_list = Hash.new
    display_groups.each do | group |
      display_groups_list.store(group.id, group.name)
    end
    display_ads = DisplayAd.where(promotion_id: params[:query]).select("id, name")
    display_ads_list = Hash.new
    display_ads.each do | ads |
      display_ads_list.store(ads.id, ads.name)
    end 
    display_campaigns = DisplayCampaign.where(promotion_id: params[:query]).select("id, name")
    display_campaigns_list = Hash.new
    display_campaigns.each do | campaign |
      display_campaigns_list.store(campaign.id, campaign.name)
    end 
    
    accounts = Account.where(promotion_id: params[:query]).select("id,account_name")
    accounts_list = Hash.new
    accounts.each do |account| 
      accounts_list.store(account.id, account.account_name)
    end  
    
    conversions = Conversion.select("id, conversion_name")
    conversion_categories = [I18n.t("conversion.conversion_category.web"), I18n.t("conversion.conversion_category.app.label"), I18n.t("conversion.conversion_category.combination")]
    os = { 1 => I18n.t("conversion.conversion_category.app.os.ios"), 2 => I18n.t("conversion.conversion_category.app.os.android"), 9 => I18n.t("conversion.conversion_category.app.os.other")}
    rows = Array.new
    conversion_logs.each do |conversion_log|
      if conversion_log.media_id && conversion_log.media_id.to_i > 0
        media_name = medias_list[conversion_log.media_id.to_i]
      else
        media_name = ""
      end
      
      if conversion_log.account_id && conversion_log.account_id.to_i > 0
        account_name = accounts_list[conversion_log.account_id.to_i]
      else
        account_name = ""
      end
      
      if conversion_log.campaign_id && conversion_log.campaign_id.to_i > 0
        campaign_name = display_campaigns_list[conversion_log.campaign_id.to_i]
      else
        campaign_name = ""
      end
      
      if conversion_log.group_id && conversion_log.group_id.to_i > 0
        group_name = display_groups_list[conversion_log.group_id.to_i]
      else
        group_name = ""
      end
      
      if conversion_log.unit_id && conversion_log.unit_id.to_i > 0
        ads_name = display_ads_list[conversion_log.unit_id.to_i]
      else
        ads_name = ""
      end
      if conversion_log.click_utime
        click_utime = Time.at(conversion_log.click_utime).strftime("%Y/%m/%d %H:%M:%S")
      else
        click_utime = ""
      end
      if conversion_log.device_category && conversion_log.device_category.to_i > 0
        os_name = os[conversion_log.device_category.to_i-1]
      else
        os_name = ""
      end
      if conversion_log.conversion_id && conversion_log.conversion_id.to_i > 0
        conversion_name = conversions.find_by_id(conversion_log.conversion_id).conversion_name
      else
        conversion_name = ""
      end
      if conversion_log.device_category && os[conversion_log.device_category.to_i]
        os_name = os[conversion_log.device_category.to_i]
      else
        os_name = ""
      end
      if conversion_log.sales && conversion_log.sales.to_i > 0
        sales_unit = number_to_currency conversion_log.sales, unit: I18n.t("cv_logs.currency"), seperator: ",", delimiter: ""
      else
        sales_unit = ""
      end 
      if conversion_log.profit && conversion_log.profit.to_i > 0
        profit = number_to_currency conversion_log.profit, unit: I18n.t("cv_logs.currency"), seperator: ",", delimiter: ""
      else
        profit = ""
      end 
      rows << {id: conversion_log.id, cell: 
        {conversion_utime: "<div title='#{Time.at(conversion_log.conversion_utime).strftime("%Y/%m/%d %H:%M:%S")}'>" + Time.at(conversion_log.conversion_utime).strftime("%Y/%m/%d %H:%M:%S") + "</div>",
         conversion_id: "<div title='#{conversions.find_by_id(conversion_log.conversion_id).conversion_name}'>" + conversions.find_by_id(conversion_log.conversion_id).conversion_name + "</div>",
         conversion_category: "<div title='#{conversion_categories[conversion_log.conversion_category.to_i-1]}'>" + conversion_categories[conversion_log.conversion_category.to_i-1] + "</div>",
         tracking_type: "<div title='#{I18n.t("log_track_type")[conversion_log.track_type.to_i-1]}'>" + I18n.t("log_track_type")[conversion_log.track_type.to_i-1] + "</div>",
         cv_type: "<div title='#{I18n.t("log_repeat_flg")[conversion_log.repeat_flg.to_i]}'>" + I18n.t("log_repeat_flg")[conversion_log.repeat_flg.to_i] + "</div>",
         approval_status: "<div title=''></div>",
         media_id: "<div title='#{media_name}'>" + media_name + "</div>",
         account_id: "<div title='#{account_name}'>" + account_name + "</div>",
         campaign_id: "<div title='#{campaign_name}'>" + campaign_name + "</div>",
         group_id: "<div title='#{group_name}'>" +  group_name + "</div>",
         unit_id: "<div title='#{ads_name}'>" + ads_name + "</div>",
         click_utime: "<div title='#{click_utime}'>" + click_utime + "</div>",
         verify: "<div title='#{conversion_log.verify}'>" + conversion_log.verify + "</div>",
         suid: "<div title='#{conversion_log.suid}'>" + conversion_log.suid + "</div>",
         session_id: conversion_log.session_id ,
         os: "<div title='#{os_name}'>" + os_name + "</div>",
         log_state: "<div title='#{conversion_log.log_state}'>" + conversion_log.log_state + "</div>",
         sales: sales_unit,
         volume: conversion_log.volume,
         others: (conversion_log.others) ? "<div title='#{conversion_log.others}'>" + conversion_log.others + "</div>" : '',
         error_code: "<div title='#{I18n.t("log_cv_error_messages")[conversion_log.error_code.to_i]}'>" + I18n.t("log_cv_error_messages")[conversion_log.error_code.to_i] + "</div>",
         media_category_id: conversion_log.media_category_id,
         profit: profit
      }}
    end
    rows
  end

  def change_accounts_list
    if params[:cid] && params[:cid].to_i > 0
      render json: Account.where(media_category_id: params[:cid]).where(promotion_id: params[:promotion_id]).order(:roman_name).select("id")
    .select("CASE WHEN LENGTH(account_name) > #{Settings.MAX_JA_LENGTH_NAME}
                                   THEN SUBSTRING(account_name, 1, #{Settings.MAX_JA_LENGTH_NAME})
                                    ELSE  account_name END as account_name ")
    else
      
      render json: Account.where(promotion_id: params[:promotion_id]).order(:roman_name).select("id")
    .select("CASE WHEN LENGTH(account_name) > #{Settings.MAX_JA_LENGTH_NAME}
                                   THEN SUBSTRING(account_name, 1, #{Settings.MAX_JA_LENGTH_NAME})
                                    ELSE  account_name END as account_name ")
    end

  end

  private
  def set_cookies
    cookies[:cv_options] = Settings.cookie_cv_log_default if !cookies[:cv_options]
    cookies[:ser] = "1" if !cookies[:ser]
  end
end
