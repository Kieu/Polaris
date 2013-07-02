class ClickLog < ActiveRecord::Base
  establish_connection "log_db_#{Rails.env}"
  attr_accessible :access_track_server, :account_id, :group_id, :unit_id,
                  :campaign_id, :click_utime, :click_url, :click_ymd, :creative_id,
                  :device_category, :mark, :media_category_id, :media_id, :media_session_id, :mpv,
                  :redirect_infomation_id, :redirect_url, :redirect_url_id, :referrer, :remote_ip,
                  :request_uri, :session_id, :user_agent, :verify, :error_code, :state

  def self.get_all_logs id, page, rp, sortname, sortorder, media_category_id, account_id, start_date, end_date, show_error
    self.table_name = "click_#{id}_logs"
    
    if !self.table_exists?
      Array.new
      return
    end
    
    start = (page.to_i-1) * rp.to_i
    start_date = Date.strptime(start_date, I18n.t("time_format")).strftime("%Y%m%d")
    end_date = Date.strptime(end_date, I18n.t("time_format")).strftime("%Y%m%d")
    params = [start_date, end_date]
    where_clause = ""
    
    if media_category_id.present?
      where_clause += " AND media_category_id=?"
      params += [media_category_id.to_i]
    end
    if account_id.present?
      where_clause += " AND account_id=? "
      params += [account_id.to_i]
    end
    
    if (show_error == "1")
      sql_str = "select id,media_category_id,media_id,account_id,campaign_id,group_id,unit_id,redirect_infomation_id,mpv,click_url,redirect_url_id,
                 creative_id,session_id,verify,request_uri,redirect_url,media_session_id,device_category,user_agent,referrer,click_utime,click_ymd,
                 remote_ip,mark,access_track_server, '0' as error_code, 'OK' as state,created_at,updated_at from click_#{id}_logs
                 where DATE_FORMAT(click_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause} union all
                 select id,media_category_id,media_id,account_id,campaign_id,group_id,unit_id,redirect_infomation_id,mpv,click_url,redirect_url_id,creative_id,
                 session_id,verify,request_uri,redirect_url,media_session_id,device_category,user_agent,referrer,click_utime,click_ymd,remote_ip,
                 mark,access_track_server,error_code, 'NG' as state,created_at,updated_at from click_error_#{id}_logs
                 where DATE_FORMAT(click_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause}
               ORDER BY media_category_id, click_utime DESC LIMIT #{start}, #{rp} "
      params += params
    else
      sql_str = "select id,media_category_id,media_id,account_id,campaign_id,group_id,unit_id,redirect_infomation_id,mpv,click_url,redirect_url_id,
                 creative_id,session_id,verify,request_uri,redirect_url,media_session_id,device_category,user_agent,referrer,click_utime,click_ymd,
                 remote_ip,mark,access_track_server, '0' as error_code, 'OK' as state,created_at,updated_at from click_#{id}_logs
               where DATE_FORMAT(click_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause}
               ORDER BY media_category_id, click_utime DESC LIMIT #{start}, #{rp}"
    end
    begin
      logs = ClickLog.find_by_sql([sql_str] + params)
    rescue 
      logs = Array.new
    end
    logs
    
  end         
  
  def self.get_logs id, media_category_id, account_id, start_date, end_date, show_error
    self.table_name = "click_#{id}_logs"
    
    #start_date = Date.strptime(start_date, I18n.t("time_format")).strftime("%Y%m%d")
    #end_date = Date.strptime(end_date, I18n.t("time_format")).strftime("%Y%m%d")
    params = [start_date, end_date]
    where_clause = ""
    if media_category_id.present?
      where_clause += " AND media_category_id=?"
      params += [media_category_id.to_i]
    end
    if account_id.present?
      where_clause += " AND account_id=? "
      params += [account_id.to_i]
    end
    if (show_error == "1")
      sql_str = "select id,media_category_id,media_id,account_id,campaign_id,group_id,unit_id,redirect_infomation_id,mpv,click_url,redirect_url_id,
                 creative_id,session_id,verify,request_uri,redirect_url,media_session_id,device_category,user_agent,referrer,click_utime,click_ymd,
                 remote_ip,mark, '0' as error_code, 'OK' as state,created_at,updated_at from click_#{id}_logs
                 where DATE_FORMAT(click_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause} union all
                 select id,media_category_id,media_id,account_id,campaign_id,group_id,unit_id,redirect_infomation_id,mpv,click_url,redirect_url_id,creative_id,
                 session_id,verify,request_uri,redirect_url,media_session_id,device_category,user_agent,referrer,click_utime,click_ymd,remote_ip,
                 mark,error_code, 'NG' as state,created_at,updated_at from click_error_#{id}_logs
                 where DATE_FORMAT(click_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause}
               ORDER BY click_utime DESC "
      params += params
    else
      sql_str = "select id,media_category_id,media_id,account_id,campaign_id,group_id,unit_id,redirect_infomation_id,mpv,click_url,redirect_url_id,
                 creative_id,session_id,verify,request_uri,redirect_url,media_session_id,device_category,user_agent,referrer,click_utime,click_ymd,
                 remote_ip,mark, '0' as error_code, 'OK' as state,created_at,updated_at from click_#{id}_logs
               where DATE_FORMAT(click_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause}
               ORDER BY click_utime DESC "
    end
    
    @logs = ClickLog.find_by_sql([sql_str] + params)
  end         
  
  
  def self.get_log_count id, media_category_id, account_id, start_date, end_date, show_error
    self.table_name = "click_#{id}_logs"
    if !self.table_exists?
      return 0
    end
    
    start_date = Date.strptime(start_date, I18n.t("time_format")).strftime("%Y%m%d")
    end_date = Date.strptime(end_date, I18n.t("time_format")).strftime("%Y%m%d")
    params = [start_date, end_date]
    where_clause = ""
    
    if media_category_id.present?
      where_clause += " AND media_category_id=?"
      params += [media_category_id.to_i]
    end
    if account_id.present?
      where_clause += " AND account_id=? "
      params += [account_id.to_i]
    end
    if (show_error == "1")
      sql_str = "select count(*) as cnt from (select id from click_#{id}_logs 
               where DATE_FORMAT(click_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause} union all
               select id from click_error_#{id}_logs 
               where DATE_FORMAT(click_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause} ) as logs "
      params += params
    else
      sql_str = "select count(id) as cnt from click_#{id}_logs 
               where DATE_FORMAT(click_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause} "
    end
    @count = ClickLog.find_by_sql([sql_str] + params)
    @count[0]["cnt"].to_i
  end         
end
