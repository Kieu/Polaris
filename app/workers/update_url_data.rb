# encoding: utf-8
require 'csv'
require 'uri'

# export promotion data table from promotion screen to csv file
class UpdateUrlData
  include Resque::Plugins::Status
  @queue = :update_url_data
  # define column in sv file
  LAST_MODIFIED = 0
  AD_ID = 1
  CAMPAIGN_NAME = 2
  GROUP_NAME = 3
  AD_NAME = 4
  CREATIVE_ID = 5
  COMMENT = 6
  CLICK_UNIT = 7
  SUBMIT_URL = 8
  REDIRECT_URL1 = 9
  NAME1 = 10
  RATE1 = 11
  REDIRECT_URL2 = 12
  NAME2 = 13
  RATE2 = 14
  REDIRECT_URL3 = 15
  NAME3 = 16
  RATE3 = 17
  REDIRECT_URL4 = 18
  NAME4 = 19
  RATE4 = 20
  REDIRECT_URL5 = 21
  NAME5 = 22
  RATE5 = 23

  def perform
    # get params
    promotion_id = options['promotion_id'].to_i
    account_id = options['account_id'].to_i
    media_category_id = options['media_category_id'].to_i
    media_id = options['media_id'].to_i
    type = options['type']
    user_id = options['user_id']
    client_id = options['client_id'].to_i

    I18n.locale = options['lang']
    lang = options['lang']

    # file fomat: {user_id}_import_url_{current date}.csv
    data_file = options['file']

    # get client_name, promotion_name, account_name
    promotion_name = Promotion.where(id: promotion_id).select("roman_name").first['roman_name']
    client_name = Client.where(id: client_id).select("roman_name").first['roman_name']
    account_name = Account.where(id: account_id).select("roman_name").first['roman_name']
    header_error_file = client_name + "_" + promotion_name + "_" + account_name + "_"
 
    # get job_id
    job_id = BackgroundJob.where(id: options['bgj_id']).select('job_id').first['job_id']

    # make header insert string sql
    insert_redirect_url_str, delete_url_sql =  make_header_insert_sql type

    # create mpv
    mpv = media_category_id.to_s(36) + "." + promotion_id.to_s(36) + "." + account_id.to_s(36)

     # file fomat: {process_id}_error.txt
     error_file = Settings.error_url_path + "#{job_id}.txt"
     File.open(error_file, 'w') do |error|
       begin
         if !File.exists?(data_file)
           error.write(I18n.t("error_message_url_import.unexpected_error"))
           background_job = BackgroundJob.find(options['bgj_id'])

           # false case
           background_job.status = Settings.job_status.WRONG
           background_job.filename = header_error_file + Time.now.strftime("%Y%m%d") + Settings.file_type.TXT
           background_job.filepath = error_file
           background_job.save!
          
           return
         end

         row_number = CSV.readlines(data_file).size

         if row_number > Settings.MAX_LINE_URL_IMPORT_FILE
           error.write(I18n.t("error_message_url_import.over_row"))
           background_job = BackgroundJob.find(options['bgj_id'])

           # false case
           background_job.status = Settings.job_status.WRONG
           background_job.filename = header_error_file + Time.now.strftime("%Y%m%d") + Settings.file_type.TXT
           background_job.filepath = error_file
           background_job.save!
          
           return
         end

         array_ads = Array.new
         array_redirect_info = Array.new
         array_redirect_url = Array.new
         array_ad_id_insert = Array.new
         array_ad_name_insert = Array.new
         array_double_data = Hash.new
         insert_redirect_info_str = " "
         num = 0
         error_num = 0
         line_num = 0

         # get identifier from display_ads
         array_identifer = Array.new
         array_identifer_ads = DisplayAd.where(" del_flg = 0 and promotion_id = #{promotion_id} ")
                                        .select(' identifier ')
         if array_identifer_ads.count > 0
          array_identifer_ads.each do |identifier|
            array_identifer << identifier.identifier
          end 
         end
         
         # get array creative id
         array_creative_id = Array.new
         creative_result = Creative.select('id')
         creative_result.each do |creative|
           array_creative_id << creative.id
         end

         #initial transaction
         ActiveRecord::Base.transaction do
           # read data from csv file that uploaded
           CSV.foreach(data_file) do |row|
             row_number -= 1
             line_num += 1
             if(line_num == 1)
               next
             end
             
             # validate data input
             row, error_num, array_identifer, 
             array_ad_id_insert, array_ad_name_insert, 
             array_creative_id, current_mpv = validate_data_input num, error_num, row, error, array_identifer, 
                                                     array_ad_id_insert, array_ad_name_insert, 
                                                     array_creative_id, line_num, array_double_data,
                                                     mpv, client_id, promotion_id, lang, account_id

             # start insert data to DB
             if error_num == 0
               num += 1
               current_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
               comma_sql = " , "
               if num == 1
                 comma_sql = ""
               end
              
              delete_url_sql += "
                                and mpv = '#{current_mpv}' 

                                "

               # insert redirect infomation
               insert_redirect_info_str = "
                                            update redirect_informations set creative_id = #{row[CREATIVE_ID]},
                                                                      comment = '#{row[COMMENT]}',
                                                                      click_unit = #{row[CLICK_UNIT]},
                                                                      updated_at = NOW()
                                                                      update_user_id = #{user_id}
                                                              where mpv = '#{current_mpv}'
                                                                      ;

                                            "
               
               result = ActiveRecord::Base.connection.execute(insert_redirect_info_str)

               # insert url
               insert_redirect_url_str += "#{comma_sql}('#{current_mpv}', '#{row[REDIRECT_URL1]}', #{row[RATE1]}, '#{row[NAME1]}',
                                            #{user_id}, NOW(), NOW(), #{user_id} )

                                            "
               
               if row[REDIRECT_URL2] != ""
                 insert_redirect_url_str += " , ('#{current_mpv}', '#{row[REDIRECT_URL2]}', #{row[RATE2]}, '#{row[NAME2]}',
                                             #{user_id}, NOW(), NOW(), #{user_id} )

                                            "
                 num += 1
               end

               if row[REDIRECT_URL3] != ""
                 insert_redirect_url_str += " , ('#{current_mpv}', '#{row[REDIRECT_URL3]}', #{row[RATE3]}, '#{row[NAME3]}',
                                             #{user_id}, NOW(), NOW(), #{user_id} )

                                            "
                 num += 1
               end

               if row[REDIRECT_URL4] != ""
                 insert_redirect_url_str += " , ('#{current_mpv}', '#{row[REDIRECT_URL4]}', #{row[RATE4]}, '#{row[NAME4]}',
                                             #{user_id}, NOW(), NOW(), #{user_id} )

                                            "
                 num += 1
               end

               if row[REDIRECT_URL5] != ""
                 insert_redirect_url_str += " , ('#{current_mpv}', '#{row[REDIRECT_URL5]}', #{row[RATE5]}, '#{row[NAME5]}',
                                             NOW(), NOW(), #{user_id} )
                                            "
                 num += 1
               end

               if num == Settings.RECORD_NUM_PER_INSERT || (row_number == 0)
                 # delete all redirect URL before insert
                 result = ActiveRecord::Base.connection.execute(delete_url_sql)
                 result = ActiveRecord::Base.connection.execute(insert_redirect_url_str)
                 # make header insert string sql
                 insert_redirect_info_str = " "
                 insert_redirect_url_str, delete_url_sql =  make_header_insert_sql type

                 num = 0
               end

             end

           end
           
           if error_num > 0
             background_job = BackgroundJob.find(options['bgj_id'])
             # false case
             background_job.status = Settings.job_status.WRONG
             background_job.filename = header_error_file + Time.now.strftime("%Y%m%d") + Settings.file_type.TXT
             background_job.filepath = error_file
             background_job.save!
             raise ActiveRecord::Rollback
           end
         end

         # commit transation
         background_job = BackgroundJob.find(options['bgj_id'])
         if error_num == 0
           # false case
           background_job.status = Settings.job_status.SUCCESS
           background_job.filepath = data_file
         else
           background_job.status = Settings.job_status.WRONG
           background_job.filename = header_error_file + Time.now.strftime("%Y%m%d") + Settings.file_type.TXT
           background_job.filepath = error_file
         end
         background_job.save!
         if error_num == 0
           File.delete(error_file)
         end
         
       rescue
         background_job = BackgroundJob.find(options['bgj_id'])
         # false case
         background_job.status = Settings.job_status.WRONG
         background_job.filename = header_error_file + Time.now.strftime("%Y%m%d") + Settings.file_type.TXT
         background_job.filepath = error_file
         background_job.save!
         error.write(I18n.t("error_message_url_import.unexpected_error"))
       end
     end

     File.delete(data_file)
  end

  private
  def is_numeric?(obj) 
    obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  def valid?(url)
    uri = URI.parse(url)
    uri.kind_of?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end

  def make_header_insert_sql type
    update_str = " , updated_at, created_at, update_user_id "
    insert_redirect_url_str = "
                  insert into redirect_urls 
                   (mpv, url, rate, name, create_user_id #{update_str} )
                  values

                  "
    
    delete_url_sql = "
                     delete from redirect_urls where
                     1 = 1
                     "
    return insert_redirect_url_str, delete_url_sql
  end


  def validate_data_input num, error_num, row, error, 
                          array_identifer, array_ad_id_insert, 
                          array_ad_name_insert, array_creative_id, line_num, array_double_data,
                          mpv, client_id, promotion_id, lang, account_id
     
     # LAST_MODIFIED field
     row[LAST_MODIFIED] = row[LAST_MODIFIED].to_s.strip
     
     line_en = I18n.t("error_message_url_import.line")
     line_jp = I18n.t("error_message_url_import.line")
     enter_key = I18n.t("error_message_url_import.enter_key")
     array_campaigns = Array.new
     array_groups = Array.new

     if lang == 'en'
       line_jp = ""
     else
       line_en = ""
     end

     # AD_ID field
     row[AD_ID] = row[AD_ID].to_s.strip
     if row[AD_ID] != ""
       if array_identifer.include?(row[AD_ID].to_i)
         error_num += 1
         error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.ad_id_already_used") + "#{enter_key}")
       end

       if is_numeric? row[AD_ID] != true
         error_num += 1
         error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.ad_id_invalid") + "#{enter_key}")
       end

       if array_ad_id_insert.count > 0 && array_ad_id_insert.include?(row[AD_ID].to_i)
         error_num += 1
         error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.ad_id_used_same_file") + "#{enter_key}")
       end

       array_ad_id_insert << row[AD_ID]
     end
     
     # CAMPAIGN_NAME field
     row[CAMPAIGN_NAME] = row[CAMPAIGN_NAME].to_s.strip
     if row[CAMPAIGN_NAME] == ""
        error_num += 1
        error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.campaign_name_not_type") + "#{enter_key}")
     else
       # check campaign existed or not
       array_campaigns = DisplayCampaign.where(" name = '#{row[CAMPAIGN_NAME]}' and account_id = #{account_id}").select('id')
       if array_campaigns.count == 0
         error_num += 1
         error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.campaign_name_must_exist") + "#{enter_key}")
       end
     end
     
     # GROUP_NAME
     row[GROUP_NAME] = row[GROUP_NAME].to_s.strip
     if row[GROUP_NAME] == ""
        error_num += 1
        error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.group_name_not_type") + "#{enter_key}")
     else
        # check group existed or not
        if array_campaigns.count > 0
          display_campaign_id = array_campaigns.first['id']
          array_groups = DisplayGroup.where(" name = '#{row[GROUP_NAME]}' and display_campaign_id = #{display_campaign_id}").select('id')
          if array_groups.count == 0
            error_num += 1
            error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.group_name_must_exist") + "#{enter_key}")
          else
            display_group_id = array_groups.first['id']
          end
          
        end
     end

     # AD_NAME
     ad_id_identifier = ""
     row[AD_NAME] = row[AD_NAME].to_s.strip
     if row[AD_NAME] != ""
        # check ad existed or not
        if array_campaigns.count > 0 && array_groups.count > 0
          array_ads = DisplayAd.where(" name = '#{row[AD_NAME]}' and display_group_id = #{display_group_id}").select('id, identifier')
          if array_ads.count == 0
            error_num += 1
            error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.camp_group_ad_must_match") + "#{enter_key}")
          else
            ad_id_identifier = array_ads.first['identifier'].to_s
          end
        end
        
        array_ad_name_insert << row[AD_NAME]
     else
        error_num += 1
        error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.ad_name_not_type") + "#{enter_key}")

     end

     # check submit URL
     # make current_mpv
     if ad_id_identifier != ""
       current_ad_id = DisplayAd.where(identifier: ad_id_identifier).select('id').first['id']
       current_mpv = mpv + "." + current_ad_id.to_s(36)
       if row[AD_ID] == ""
         # make current submit_url
         current_submit_url = Settings.DOMAIN_SUBMIT_URL + "mpv=#{current_mpv}&plrs_cid=#{client_id}&plrs_pid=#{promotion_id}"
         row[SUBMIT_URL] = row[SUBMIT_URL].to_s.strip
         if (row[SUBMIT_URL] != "") && (row[SUBMIT_URL] != current_submit_url)
           error_num += 1
           error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.camp_group_ad_submit_must_match") + "#{enter_key}")
         end
       elsif row[AD_ID] != "" && row[AD_ID] != ad_id_identifier
         error_num += 1
         error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.ad_identifier_must_match") + "#{enter_key}")
       end
     end
     
     # check double [Campaign name] [group name] [ad name]
     key_str = "#{row[CAMPAIGN_NAME]}_#{row[GROUP_NAME]}_#{row[AD_NAME]}"
     
     if !array_double_data[key_str]
       array_double_data[key_str] = line_num.to_s
     else
       array_double_data[key_str] += "," + line_num.to_s
       error_num += 1
       error.write("#{line_en}#{array_double_data[key_str]}#{line_jp}: " + I18n.t("error_message_url_import.name_overlapped") + "#{enter_key}")
     end

     # CREATIVE_ID field
     row[CREATIVE_ID] = row[CREATIVE_ID].to_s.strip
     if row[CREATIVE_ID] != ""
       if !is_numeric? row[CREATIVE_ID]
         error_num += 1
         error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.creative_id_half_width") + "#{enter_key}")
       end
       
       if row[CREATIVE_ID].length > 20
          error_num += 1
          error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.creative_id_too_long") + "#{enter_key}")
       end

       if !array_creative_id.include?(row[CREATIVE_ID].to_i)
         error_num += 1
         error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.creative_id_not_exist") + "#{enter_key}")
       end
       
     end

     # COMMENT field
     row[COMMENT] = row[COMMENT].to_s.strip

     # CLICK_UNIT field
     row[CLICK_UNIT] = row[CLICK_UNIT].to_s.strip
     if row[CLICK_UNIT] != ""
       if !is_numeric? row[CLICK_UNIT]
         error_num += 1
         error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.unit_click_price_half_width") + "#{enter_key}")
       end
     end

     # REDIRECT_URL1 ==============================================
    row[REDIRECT_URL1] = row[REDIRECT_URL1].to_s.strip
    if row[REDIRECT_URL1] == ""
      error_num += 1
      if lang == 'en'
        error.write("Line #{line_num}: URL is not specified in 1.\n")
      else
        error.write("#{line_num}#{line_jp}:リンク先1にURLが指定されていません。\n")
      end
    end

    #NAME1
    row[NAME1] = row[NAME1].to_s.strip
    if row[NAME1] != ""
      if row[NAME1].length > 255
        error_num += 1
        if lang == 'en'
          error.write("Line#{line_num}: Title 1 needs to be less than 255 letters.\n")
        else
          error.write("#{line_num}#{line_jp}:タイトル1は文字数の上限255文字を超えています。\n")
        end
      end
    else
      error_num += 1
      if lang == 'en'
        error.write("Line#{line_num}: Title 1 is not typed.\n")
      else
        error.write("#{line_num}#{line_jp}:タイトル1が記入されておりません。\n")
      end
    end

    #RATE1
    row[RATE1] = row[RATE1].to_s.strip
    if row[RATE1] != ""
      if !is_numeric? row[RATE1]
        error_num += 1
        if lang == 'en'
          error.write("Line#{line_num}: Please type Transition rate1 with half-width characters. \n")
        else
          error.write("#{line_num}#{line_jp}:遷移割合1は半角数字で入力してください。\n")
        end
        
      end
    else
      error_num += 1
      if lang == 'en'
        error.write("Line #{line_num}: RATE 1 is not typed.\n")
      else
        error.write("#{line_num}#{line_jp}:遷移割合1が記入されておりません。\n")
      end
      
    end

    # REDIRECT_URL2 ==============================================
    row[REDIRECT_URL2] = row[REDIRECT_URL2].to_s.strip

    #NAME2
    row[NAME2] = row[NAME2].to_s.strip
    if row[NAME2] != ""
      if row[NAME2].length > 255
        error_num += 1
        if lang == 'en'
          error.write("Line#{line_num}: Title 2 needs to be less than 255 letters.\n")
        else
          error.write("#{line_num}#{line_jp}:タイトル2は文字数の上限255文字を超えています。\n")
        end
      end
    end

    #RATE2
    row[RATE2] = row[RATE2].to_s.strip
    if row[RATE2] != ""
      if !is_numeric? row[RATE2]
        error_num += 1
        if lang == 'en'
          error.write("Line#{line_num}: Please type Transition rate2 with half-width characters.\n")
        else
          error.write("#{line_num}#{line_jp}:遷移割合2は半角数字で入力してください。\n")
        end
      end
    end

    if !((row[REDIRECT_URL2] != "") && (row[NAME2] != "") && (row[RATE2] != "")) &&
        !((row[REDIRECT_URL2] == "") && (row[NAME2] == "") && (row[RATE2] == ""))
      error_num += 1
      if lang == 'en'
        error.write("Line#{line_num}: REDIRECT_URL2, NAME2, RATE2 have typed together or blank together.\n")
      else
        error.write("#{line_num}#{line_jp}:リンク先２、タイトル２、遷移割合２は一緒に入力必須です。もしくは一緒に空欄にしてください。\n")
      end
      
    end

    # REDIRECT_URL3 ==============================================
    row[REDIRECT_URL3] = row[REDIRECT_URL3].to_s.strip

    #NAME3
    row[NAME3] = row[NAME3].to_s.strip
    if row[NAME3] != ""
      if row[NAME3].length > 255
        error_num += 1
        if lang == 'en'
          error.write("Line#{line_num}: Title 3 needs to be less than 255 letters.\n")
        else
          error.write("#{line_num}#{line_jp}:タイトル3は文字数の上限255文字を超えています。\n")
        end
      end
    end

    #RATE3
    row[RATE3] = row[RATE3].to_s.strip
    if row[RATE3] != ""
      if !is_numeric? row[RATE3]
        error_num += 1
        if lang == 'en'
          error.write("Line#{line_num}: Please type Transition rate3 with half-width characters.\n")
        else
          error.write("#{line_num}#{line_jp}:遷移割合3は半角数字で入力してください。\n")
        end
      end
    end

    if !((row[REDIRECT_URL3] != "") && (row[NAME3] != "") && (row[RATE3] != "")) &&
        !((row[REDIRECT_URL3] == "") && (row[NAME3] == "") && (row[RATE3] == ""))
      error_num += 1
      if lang == 'en'
        error.write("Line#{line_num}: REDIRECT_URL3, NAME3, RATE3 have typed together or blank together.\n")
      else
        error.write("#{line_num}#{line_jp}:リンク先3、タイトル3、遷移割合3は一緒に入力必須です。もしくは一緒に空欄にしてください。\n")
      end
      
    end

    # REDIRECT_URL4 ==============================================
    row[REDIRECT_URL4] = row[REDIRECT_URL4].to_s.strip

    #NAME4
    row[NAME4] = row[NAME4].to_s.strip
    if row[NAME4] != ""
      if row[NAME4].length > 255
        error_num += 1
        if lang == 'en'
          error.write("Line#{line_num}: Title 4 needs to be less than 255 letters.\n")
        else
          error.write("#{line_num}#{line_jp}:タイトル4は文字数の上限255文字を超えています。\n")
        end
        
      end
    end

    #RATE4
    row[RATE4] = row[RATE4].to_s.strip
    if row[RATE4] != ""
      if !is_numeric? row[RATE4]
        error_num += 1
        if lang == 'en'
          error.write("Line#{line_num}: Please type Transition rate4 with half-width characters.\n")
        else
          error.write("#{line_num}#{line_jp}:遷移割合4は半角数字で入力してください。\n")
        end
        
      end
    end

    if !((row[REDIRECT_URL4] != "") && (row[NAME4] != "") && (row[RATE4] != "")) &&
        !((row[REDIRECT_URL4] == "") && (row[NAME4] == "") && (row[RATE4] == ""))
      error_num += 1
      if lang == 'en'
        error.write("Line#{line_num}: REDIRECT_URL4, NAME4, RATE4 have typed together or blank together.\n")
      else
        error.write("#{line_num}#{line_jp}:リンク先4、タイトル4、遷移割合4は一緒に入力必須です。もしくは一緒に空欄にしてください。\n")
      end
      
    end
    # REDIRECT_URL5 ==============================================
    row[REDIRECT_URL5] = row[REDIRECT_URL5].to_s.strip

    #NAME5
    row[NAME5] = row[NAME5].to_s.strip
    if row[NAME5] != ""
      if row[NAME5].length > 255
        error_num += 1
        if lang == 'en'
          error.write("Line#{line_num}: Title 5 needs to be less than 255 letters.\n")
        else
          error.write("#{line_num}#{line_jp}:タイトル5は文字数の上限255文字を超えています。\n")
        end
        
      end
    end

    #RATE5
    row[RATE5] = row[RATE5].to_s.strip
    if row[RATE5] != ""
      if !is_numeric? row[RATE5]
        error_num += 1
        if lang == 'en'
          error.write("Line#{line_num}: Please type Transition rate5 with half-width characters.\n")
        else
          error.write("#{line_num}#{line_jp}:遷移割合5は半角数字で入力してください。\n")
        end
        
      end
    end

    if !((row[REDIRECT_URL5] != "") && (row[NAME5] != "") && (row[RATE5] != "")) &&
        !((row[REDIRECT_URL5] == "") && (row[NAME5] == "") && (row[RATE5] == ""))
      error_num += 1
      if lang == 'en'
        error.write("Line#{line_num}: REDIRECT_URL5, NAME5, RATE5 have typed together or blank together.\n")
      else
        error.write("#{line_num}#{line_jp}:リンク先5、タイトル5、遷移割合5は一緒に入力必須です。もしくは一緒に空欄にしてください。\n")
      end
      
    end

    # check total rate is 100
    if (row[RATE5].to_i + row[RATE4].to_i + row[RATE3].to_i + row[RATE2].to_i + row[RATE1].to_i) != 100
      error_num += 1
      error.write("#{line_en}#{line_num}#{line_jp}: " + I18n.t("error_message_url_import.transition_rake_altogether") + "#{enter_key}")
    end

    return row, error_num, array_identifer, array_ad_id_insert, array_ad_name_insert, array_creative_id, current_mpv
  end

end