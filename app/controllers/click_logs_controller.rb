require "resque"
class ClickLogsController < ApplicationController
  before_filter :signed_in_user
  before_filter :set_cookie
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
        Promotion.active.get_by_client(@client_id).order_by_promotion_name

    @array_account = Account.where(promotion_id: params[:promotion_id]).order(:roman_name).select("id")
                           .select("CASE WHEN LENGTH(account_name) > #{Settings.MAX_JA_LENGTH_NAME}
                                   THEN SUBSTRING(account_name, 1, #{Settings.MAX_JA_LENGTH_NAME})
                                    ELSE  account_name END as account_name ")
  end

  def get_logs_list
    rows = get_rows(ClickLog.get_all_logs(params[:query], params[:page], params[:rp], params[:sortname], params[:sortorder],
     params[:media_category_id], params[:account_id], params[:start_date].strip, params[:end_date].strip, cookies[:cser] ))
    render json: {page: params[:page], total: ClickLog.get_log_count(params[:query].to_i, params[:media_category_id], params[:account_id], params[:start_date].strip, params[:end_date].strip, cookies[:cser] ), rows: rows}
    
  end  
  
  def download_csv
    
    start_date = Date.strptime(params[:start_date].strip, I18n.t("time_format")).strftime("%Y%m%d")
    end_date = Date.strptime(params[:end_date].strip, I18n.t("time_format")).strftime("%Y%m%d")
    promotion = Promotion.find(params[:promotion_id].to_i)
    
    header_titles_csv = [I18n.t('export_click_logs.click_utime'), I18n.t('export_click_logs.click_id'), I18n.t('export_click_logs.client_name'), I18n.t('export_click_logs.promotion_name'), I18n.t('export_click_logs.media_name'), 
                      I18n.t('export_click_logs.account_name'), I18n.t('export_click_logs.campaign_name'), I18n.t('export_click_logs.ad_group'), I18n.t('export_click_logs.ad_name'),
                      I18n.t('export_click_logs.request_uri'), I18n.t('export_click_logs.redirect_url'), I18n.t('export_click_logs.session_id'), I18n.t('export_click_logs.media_session'), I18n.t('export_click_logs.os'),
                      I18n.t('export_click_logs.user_agent'),I18n.t('export_click_logs.remote_ip'), I18n.t('export_click_logs.referer'), I18n.t('export_click_logs.mark'), I18n.t('export_click_logs.ok_ng'), I18n.t('export_click_logs.error_code')]
    
    breadcrumb = "#{promotion.client.client_name} > #{promotion.promotion_name} > CV Logs"
    background_job = BackgroundJob.create
    job_id = ExportClickLogsData.create(user_id: current_user.id,
    promotion_id: params[:promotion_id].to_i,
    media_category_id: params[:media_category_id],
    account_id: params[:account_id], start_date: start_date,
    end_date: end_date, show_error: cookies[:cser],
    breadcrumb: breadcrumb,
    lang: cookies[:locale],
    header_titles_csv: header_titles_csv,
    bgj_id: background_job.id)
    background_job.user_id =  current_user.id
    background_job.breadcrumb =  breadcrumb
    background_job.job_id = job_id
    background_job.type_view = Settings.type_view.DOWNLOAD
    background_job.status = Settings.job_status.PROCESSING
    background_job.save!
    render text: "processing"
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
  def get_rows click_logs
    
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
    os = { 1 => I18n.t("conversion.conversion_category.app.os.ios"), 2 => I18n.t("conversion.conversion_category.app.os.android"), 9 => I18n.t("conversion.conversion_category.app.os.other")}
    rows = Array.new
      if click_logs && click_logs.count > 0
        click_logs.each do |log|
          if log.media_id && log.media_id.to_i > 0
            media_name = medias_list[log.media_id]
          else
            media_name = ''
          end
            
          rows << {id: log.id, cell: {
                  click_utime: Time.at(log.click_utime.to_i).strftime("%Y/%m/%d %H:%M:%S"),
                  media_id: "<div title='#{media_name}'>" + media_name + "</div>", 
                  media_category_id: log.media_category_id,
                  account_id: "<div title='#{accounts.find(log.account_id).account_name}'>" + accounts.find(log.account_id).account_name + "</div>", 
                  campaign_id: "<div title='#{display_campaigns.find(log.campaign_id).name}'>" + display_campaigns.find(log.campaign_id).name + "</div>", 
                  group_id: "<div title='#{display_groups.find(log.group_id).name}'>" + display_groups.find(log.group_id).name + "</div>", 
                  unit_id: "<div title='#{display_ads.find(log.unit_id).name}'>" + display_ads.find(log.unit_id).name + "</div>", 
                  redirect_url: "<div title='#{log.redirect_url}'>" + log.redirect_url + "</div>", 
                  session_id: "<div title='#{log.session_id}'>" + log.session_id + "</div>", 
                  device_category: "<div title='#{os[log.device_category.to_i]}'>" + os[log.device_category.to_i] + "</div>", 
                  state: "<div title='#{log.state}'>" + log.state + "</div>", 
                  error_code: "<div title='#{I18n.t("log_error_messages")[log.error_code.to_i]}'>" + I18n.t("log_error_messages")[log.error_code.to_i] + "</div>", 
                  }}
        end
      end
    rows
  end  
  
  def set_cookie
    cookies[:coptions]=Settings.cookie_click_log_default if !cookies[:coptions]
    cookies[:cser] = "1" if !cookies[:cser]
  end
end
