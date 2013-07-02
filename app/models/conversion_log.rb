class ConversionLog < ActiveRecord::Base
  establish_connection "log_db_#{Rails.env}"

    FIELD = "media_category_id, conversion_utime, conversion_id, conversion_category, track_type, repeat_flg,
              approval_status, media_id,account_id, campaign_id,group_id, unit_id, click_utime, verify,
              suid, session_id, device_category,  repeat_processed_flg,'OK' as log_state, sales, profit, volume, others, '0' as error_code, null as error_log_view"
    FIELD_ERROR = "media_category_id, conversion_utime, conversion_id, conversion_category, track_type, null as repeat_flg,
              approval_status, media_id,account_id, campaign_id,group_id, unit_id, click_utime, verify,
              suid, session_id, device_category, null as repeat_processed_flg, 'NG' as log_state , sales, profit, volume, others, error_code, null as error_log_view"

    FIELD_ORGANIC = "1000 as media_category_id, conversion_utime, conversion_id, conversion_category,null as track_type, null as repeat_flg,
              null as approval_status, null as media_id,null as account_id, null as campaign_id,null as group_id, null as unit_id, null as click_utime, verify,
              suid, null as session_id, null as device_category, null as repeat_processed_flg,'OGANIC' as log_state, sales, profit, volume, others, '0' as error_code, null as error_log_view"

    def self.get_all_logs id, page, rp, cv_id, media_category_id, account_id, start_date, end_date, show_error, sortname, sortorder
    start = (page.to_i-1) * rp.to_i
    self.table_name = "conversion_#{id}_logs" 
    if !self.table_exists?
      Array.new
      return
    end
    
    where_clause = ""
    start_date = Date.strptime(start_date, I18n.t("time_format")).strftime("%Y%m%d")
    end_date = Date.strptime(end_date, I18n.t("time_format")).strftime("%Y%m%d")
    params = [start_date, end_date]
    params1 = [start_date, end_date]
    organic = 1
    if(cv_id.present?)  
      where_clause += " AND conversion_id = ?"
      params += [cv_id]
      params1 += [cv_id]
      organic = 0
    end
    if(media_category_id.present?)  
      where_clause += " AND media_category_id = ?"
      params += [media_category_id]
      params1 += [media_category_id]
      organic = 0
    end
    if(account_id.present?)  
      where_clause += " AND account_id = ?"
      params += [account_id]
      params1 += [account_id]
      organic = 0
    end
    sql_organic = ''
    if organic == 1
      sql_organic = " union all (select #{FIELD_ORGANIC} from conversion_organic_#{id}_logs) "
    end
    
    if show_error=="1"
      sql_str = "(select #{FIELD} from conversion_#{id}_logs  where DATE_FORMAT(conversion_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause}) union all
                                       (select #{FIELD_ERROR} from conversion_error_#{id}_logs where DATE_FORMAT(conversion_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause})
                                       #{sql_organic}
                                       ORDER BY media_category_id, #{sortname} #{sortorder} LIMIT #{start}, #{rp} "
                                        
      params += params1
    else
      sql_str = "(select #{FIELD} from conversion_#{id}_logs  where DATE_FORMAT(conversion_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause})
                                        #{sql_organic} 
                                       ORDER BY media_category_id, #{sortname} #{sortorder} LIMIT #{start}, #{rp} "
                                        
    end        
    @logs = ConversionLog.find_by_sql([sql_str] + params)
  end

  def self.get_logs id, cv_id, media_category_id, account_id, start_date, end_date, show_error
    field = "id,media_category_id,media_id,account_id,campaign_id,group_id,unit_id,conversion_id,redirect_infomation_id,mpv,redirect_url_id,
creative_id,session_id,verify,suid,request_uri,redirect_url,media_session_id,device_category,user_agent,referrer,click_referrer,
conversion_utime,conversion_ymd, click_utime,remote_ip,mark,conversion_category,track_type,repeat_flg,
repeat_processed_flg,parent_conversion_id,sales,profit,volume,others,approval_status,send_url,send_utime,access_track_server,'OK' as log_state, null as error_code,created_at,updated_at"
    field_error = "id,media_category_id,media_id,account_id,campaign_id,group_id,unit_id,conversion_id,redirect_infomation_id,mpv,redirect_url_id,
creative_id,session_id,verify,suid,request_uri,redirect_url,media_session_id,device_category,user_agent,referrer,click_referrer,
conversion_utime,conversion_ymd,click_utime,remote_ip,mark,conversion_category,track_type,null as repeat_flg,null as repeat_processed_flg,null as parent_conversion_id,sales,profit,volume,others,approval_status,null as send_url,null send_utime,access_track_server,'NG' as log_state,error_code,created_at,updated_at"

    field_organic = "id,null as media_category_id,null as media_id,null as account_id,null as campaign_id,null as group_id,null as unit_id,conversion_id,null as redirect_infomation_id,null as mpv,null as redirect_url_id,null as creative_id,null as session_id,verify,suid,request_uri,null as redirect_url,null as media_session_id,device_category,user_agent,referrer,null as click_referrer,
conversion_utime,conversion_ymd,null as click_utime,remote_ip,null as mark,conversion_category,track_type,repeat_flg,
repeat_processed_flg,parent_conversion_id,sales,profit,volume,others,null as approval_status,null as send_url,null as send_utime,access_track_server,'organic' as log_state,null as error_code,created_at,updated_at"
    
    self.table_name = "conversion_#{id}_logs" 
    if !self.table_exists?
      return 0
    end
    
    where_clause = ""
    #start_date = Date.strptime(start_date, I18n.t("time_format")).strftime("%Y%m%d")
    #end_date = Date.strptime(end_date, I18n.t("time_format")).strftime("%Y%m%d")
    params = [start_date, end_date]
    params1 = [start_date, end_date]
    params_organic = [start_date, end_date]
    organic = 1
    if(cv_id.present?)
      where_clause += " AND conversion_id = ?"
      params += [cv_id]
      params1 += [cv_id]
      organic = 0
      params_organic = Array.new
    end
    if(media_category_id.present?)
      where_clause += " AND media_category_id = ?"
      params += [media_category_id]
      params1 += [media_category_id]
      organic = 0
      params_organic = Array.new
    end
    if(account_id.present?)
      where_clause += " AND account_id = ?"
      params += [account_id]
      params1 += [account_id]
      organic = 0
      params_organic = Array.new
    end
    
    sql_organic = ''
    if organic == 1
      sql_organic = " union all (select #{field_organic} from conversion_organic_#{id}_logs where DATE_FORMAT(conversion_ymd, '%Y%m%d') BETWEEN ? AND ?) "
    end
    
    if show_error=="1"
      sql_str = "(select #{field} from conversion_#{id}_logs  where DATE_FORMAT(conversion_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause}) union all
                                       (select #{field_error} from conversion_error_#{id}_logs where DATE_FORMAT(conversion_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause}) 
                                       #{sql_organic}
                                       ORDER BY conversion_ymd DESC "
                                        
      params += params1
    else
      sql_str = "(select #{field} from conversion_#{id}_logs  where DATE_FORMAT(conversion_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause}) 
                                       #{sql_organic}
                                       ORDER BY conversion_ymd DESC "
                                        
    end             
    params += params_organic
    @logs = ConversionLog.find_by_sql([sql_str] + params)
  end
  
  def self.get_count  id, cv_id, media_category_id, account_id, start_date, end_date, show_error
    self.table_name = "conversion_#{id}_logs" 
    if !self.table_exists?
      return 0
    end
    where_clause = ""
    start_date = Date.strptime(start_date, I18n.t("time_format")).strftime("%Y%m%d")
    end_date = Date.strptime(end_date, I18n.t("time_format")).strftime("%Y%m%d")
    params = [start_date, end_date]
    params_organic = [start_date, end_date]
    params1 = [start_date, end_date]
    organic = 1
    if(cv_id.present?)  
      where_clause += " AND conversion_id = ?"
      params += [cv_id]
      params1 += [cv_id]
      organic = 0
      params_organic = Array.new
    end
    if(media_category_id.present?)  
      where_clause += " AND media_category_id = ?"
      params += [media_category_id]
      params1 += [media_category_id]
      organic = 0
      params_organic = Array.new
    end
    if(account_id.present?)  
      where_clause += " AND account_id = ?"
      params += [account_id]
      params1 += [account_id]
      organic = 0
      params_organic = Array.new
    end
    sql_organic = ''
    if organic == 1
      sql_organic = " union all select id from conversion_organic_#{id}_logs where DATE_FORMAT(conversion_ymd, '%Y%m%d') BETWEEN ? AND ? "
    end
    
    if show_error=="1"
      sql_str = "select count(*) as cnt from (select id from conversion_#{id}_logs  where DATE_FORMAT(conversion_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause} union all
                 select id from conversion_error_#{id}_logs where DATE_FORMAT(conversion_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause}
                 #{sql_organic} group by id) as logs"

      params += params1
    else
      sql_str = "select count(*) as cnt from (select id from conversion_#{id}_logs  where DATE_FORMAT(conversion_ymd, '%Y%m%d') BETWEEN ? AND ? #{where_clause} 
                #{sql_organic} group by id) as logs"
    end                          
    params += params_organic  
    @count = ConversionLog.find_by_sql([sql_str] + params)
    @count[0]["cnt"]
  end
end
