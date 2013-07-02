namespace :master do
  desc "Create role"
  task create_role: :environment do
    Role.destroy_all
    Role.create!({id: 1, role_name: "Super", status: 0}, without_protection: true)
    Role.create!({id: 2, role_name: "Client", status: 0}, without_protection: true)
    Role.create!({id: 3, role_name: "Agency", status: 0}, without_protection: true)
  end

  desc "Create Agency"
  task create_agency: :environment do
    Agency.destroy_all
    (1..100).each do |num|
      Agency.create!({id: num, agency_name: "agency_#{num}", roman_name: "agency_#{num}"},
        without_protection: true)
    end
  end

  desc "Create Client"
  task create_client: :environment do
    Client.destroy_all
    (1..100).each do |num|
      Client.create!({id: num, client_name: "client_#{num}", roman_name: "client_#{num}",
        tel: "#{num}#{num}#{num}#{num}", contract_flg: 1, contract_type: 1,
        person_charge: "person_#{num}", person_sale: "person_#{num}"},
        without_protection: true)
    end
  end
  
  desc "Create super user"
  task create_super_user: :environment do
    User.find_by_id(1).destroy if User.find_by_id(1)
    User.create!({id: 1, email: "super@septeni.com", username: "super",
      password: "123456789", role_id: 1, status: 0, roman_name: "super",
      company_id: 1, password_flg: 0}, without_protection: true)
  end

  desc "Create agency user"
  task create_agency_user: :environment do
    User.find_by_id(2).destroy if User.find_by_id(2)
    User.create!({id: 2, email: "agency@septeni.com", username: "agency",
      password: "123456789", role_id: 3, status: 0, roman_name: "agency",
      company_id: 1, password_flg: 0}, without_protection: true)
  end

  desc "Create client user"
  task create_client_user: :environment do
    User.find_by_id(3).destroy if User.find_by_id(3)
    User.create!({id: 3, email: "client@septeni.com", username: "client",
      password: "123456789", role_id: 2, status: 0, roman_name: "client",
      company_id: 1, password_flg: 0}, without_protection: true)
  end
  
  desc "Create Press Release"
  task create_press_release: :environment do
    (1..100).each do |num|
      PressRelease.create!(content: "test_#{num}", release_time: Time.now, create_user_id: 1)
    end
  end

  desc "Create Daily Summary Account"
  task create_daily_summary_account: :environment do
    (1..100).each do |num|
      DailySummaryAccount.create!(id: "#{num}", promotion_id: 1, media_category_id: 1,
                                 media_id: 1, account_id: 1, imp_count: "#{num + 10}",
                                 click_count: "#{num + 15}", cost_sum: "#{num + 30}", report_ymd: 20130525, create_time: 20130525)
    end
  end

  desc "Create Media"
  task create_media: :environment do
    (1..100).each do |num|
      Media.create!(id: "#{num}", media_category_id: 1, media_name: "media_#{num}")
    end
  end

  desc "Create Daily Summary Acc Conversion"
  task create_daily_summary_acc_conversion: :environment do
    (1..100).each do |num|
      DailySummaryAccConversion.create!(id: "#{num}", promotion_id: 1, account_id: 1,
                                 conversion_id: 1, total_cv_count: "#{num + 50}", first_cv_count: "#{num + 35}",
                                 repeat_cv_count: "#{num + 15}", assist_count: "#{num + 12}", report_ymd: 20130525, create_time: 20130525,
                                sales: "#{num + 200}", roas: "#{num + 21}", profit: "#{num + 500}", roi: "#{num + 27}")
    end
  end
  
  desc "Create Display ads"
  task create_display_ad: :environment do
    (3..100).each do |num|
      DisplayAd.create!(id: "#{num}", identifier: "identify#{num}", name: "ad#{num}",
                                 client_id: 1, promotion_id: 1, account_id: 1,display_campaign_id: 1,
                                 display_group_id: 1, create_user_id: 1, update_user_id: 1)
    end
  end
  
  desc "Create Display group"
  task create_display_group: :environment do
    (5..100).each do |num|
      DisplayGroup.create!(id: "#{num}", name: "ad_group#{num}", client_id: 1, promotion_id: 1, account_id: 1,
       create_user_id: 1, update_user_id: 1)
    end
  end
  desc "Create Display campaign"
  task create_display_campaign: :environment do
    (5..100).each do |num|
      DisplayCampaign.create!(id: "#{num}", name: "campaign#{num}", client_id: 1, promotion_id: 1, account_id: 1, create_user_id: 1, update_user_id: 1)
    end
  end

  desc "Create Promotion"
  task create_promotion: :environment do
    (1..200).each do |num|
      Promotion.create!({promotion_name: "Promotion#{num}", client_id: 1, tracking_period: 30, del_flg: 0, roman_name: "Promotion#{num}", update_user_id: 1, promotion_category_id: 1},
                       without_protection: true)
    end
  end
  desc "Create Conversion logs "
  task create_conversion_1_logs: :environment do
    (1..10000).each do |i|
      Conversion_1_Log.create(media_category_id: 1, media_id: 1, account_id: 1, campaign_id: 1, 
        group_id: 1, unit_id: 1, conversion_id: 1, redirect_infomation_id: 1, mpv: "mpv#{i}",
        redirect_url_id: 1, creative_id: 1, session_id: "session#{i}", verify: "verify#{i}", 
        suid: "suid#{i}", request_uri: "request#{i}", redirect_url: "redirect#{i}", 
        media_session_id: "media_session_#{i}", device_category: "os", user_agent: "user_egent#{i}", 
        referrer: "refferrer#{i}", click_referrer: "click_refferrer#{i}", conversion_utime: 1, 
        conversion_ymd: 1, access_time: 1, access_ymd: 1, click_time: 11, remote_ip: "remote_ip#{i}", 
        mark: "mark#{i}", conversion_category: "conversion_cate#{i}", conversion_type: "cv_type#{i}", 
        repeat_flg: "1", repeat_proccessed_flg: "1", parent_conversion_id: "1", sales: 111, 
        profit: 11, volume: 111, others: "others", approval_status: "1", send_url: "send_url", 
        send_utime: 11, access_track_server: 111)
    end
  end
  
  desc "Create Conversion error logs "
  task create_conversion_error_1_logs: :environment do
    (1..10000).each do |i|
      Conversion_error_1_Log.create(media_category_id: 1, media_id: 1, 
        account_id: 1, campaign_id: 1, group_id: 1, unit_id: 1, conversion_id: 1, 
        redirect_infomation_id: 1, mpv: "mpv#{i}", redirect_url_id: 1, creative_id: 1, 
        session_id: "session#{i}", verify: "verify#{i}", suid: "suid#{i}", request_uri: "request#{i}", 
        redirect_url: "redirect#{i}", media_session_id: "media_session_#{i}", 
        device_category: "1", user_agent: "user_egent#{i}", referrer: "refferrer#{i}", 
        click_referrer: "click_refferrer#{i}", conversion_utime: 1, conversion_ymd: 1, 
        click_time: 11, remote_ip: "remote_ip#{i}", mark: "mark#{i}", 
        conversion_category: "1", conversion_type: "1", sales: 111, profit: 11, 
        volume: 111, others: "others", approval_status: "1", access_track_server: 111)
    end
  end

  desc "Create Conversion organic logs "
  task create_conversion_organic_1_logs: :environment do
    (10..20).each do |i|
      Conversion_organic_1_Log.create(conversion_id: 1, redirect_infomation_id: 1, 
        verify: "verify#{i}", suid: "suid#{i}",  redirect_url: "redirect#{i}", 
        media_session_id: "media_session_#{i}", device_category: "1", 
        user_agent: "user_egent#{i}", referrer: "refferrer#{i}", remote_ip: "remote_ip#{i}", 
        conversion_category: "1", conversion_type: "1", sales: 111, profit: 11, 
        volume: 111, others: "others")
    end
  end

  desc "Create Click logs "
  task create_click_1_logs: :environment do
    (1..1000).each do |i|
      Click_1_Log.create(media_category_id: 1, media_id: 1, account_id: 1, campaign_id: 1, 
        group_id: 1, unit_id: 1, redirect_infomation_id: 1, mpv: "mpv#{i}", click_url: "click_url#{i}",  
        redirect_url_id: 1, creative_id: 1, session_id: "session", verify: "verify", 
        request_uri: "request_uri#{i}", redirect_url: "redirect#{i}", media_session_id: "media_sess#{i}", 
        device_category: "os", user_agent: "user_agent", referrer: "referrer", click_utime: 1, 
        click_ymd: 1, remote_ip: "remote_ip#{i}", mark: "mark#{i}", access_track_server: "access_track_server")
    end
  end

  desc "Create Conversion"
  task create_conversion: :environment do
    Conversion.destroy_all
    (1..10).each do |num|
      Conversion.create!({id: num, conversion_name: "conversion_#{num}",
        roman_name: "conversion_#{num}", promotion_id: 1, conversion_category: 0,
        duplicate: 0, unique_def: 2, start_point: 0, sale_unit_price: 100,
        reward_form: 0, create_user_id: 1}, without_protection: true)
    end
  end

  desc "Create Redirect Infomations"
  task create_redirect_infomation: :environment do
    (1..20).each do |num|
      RedirectInfomation.create!(mpv: "1.1.1.#{num}", client_id: 1, promotion_id: num, media_category_id: 1, media_id: 1, account_id: 1, campaign_id: 1, group_id: 1,
                                 unit_id: 1, creative_id: 1, click_unit: 13, del_flg: 0)
    end
  end

  desc "Create Redirect URL"
  task create_redirect_url: :environment do
    (1..10).each do |num|
      RedirectUrl.create!(mpv: "1.1.1.1", url: "http://domain/click/?mpv=MPV&cid=Client ID&pid=Promotion ID_x000D_#{num}", rate: 12, name: "url_#{num}")
    end
  end

  desc "Create Creative"
  task create_creative: :environment do
    (1..10).each do |num|
      Creative.create!(ad_id: 1, creative_name: "creative_#{num}", image: 'image1.gif', create_user_id: 1)
    end
  end
end
