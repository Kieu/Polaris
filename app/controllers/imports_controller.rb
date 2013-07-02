require 'csv'

class ImportsController < ApplicationController
  def create
    error_flg = true
    flash[:csv_error] = Array.new
    if params[:import] != nil
      content_type_file = params[:import]['csv'].content_type.strip
      array_content_type = ['text/csv','text/comma-separated-values','text/csv','application/csv','application/excel','application/vnd.ms-excel','application/vnd.msexcel','text/anytext','text/plain']
      if !array_content_type.include?(content_type_file)
        flash[:csv_error] << I18n.t('error_message_url_import.not_format_csv')
        error_flg = false
      end
    end
    
    if error_flg
      @import = Import.new(params[:import])
      origin_file_name = @import.csv_file_name
      @import.change_file_name(current_user.id) unless params[:import].nil?
      if @import.save
        file_path = @import.csv.url
        volume = File.size(file_path)
        size_field = file_size_fomat volume
        background_job = BackgroundJob.new
        background_job.user_id = current_user.id
        background_job.type_view = Settings.type_view.UPLOAD
        background_job.status = Settings.job_status.PROCESSING
        background_job.size = size_field
        background_job.filename = origin_file_name
        background_job.breadcrumb = params[:breadcrumb]
        background_job.save!

        flg_check_error, message = check_header_csv_file file_path
        if flg_check_error
          flash[:csv_error] << message
        else
          if params[:type] == 'insert'
            job_id = ImportUrlData.create(file: @import.csv.url,
                     bgj_id: background_job.id, type: params[:type], user_id: current_user.id,
                     promotion_id: params[:promotion_id], account_id: params[:account_id], 
                     media_id: params[:media_id], client_id: params[:client_id], 
                     media_category_id: params[:media_category_id], lang: cookies[:locale])

            background_job.job_id = job_id
            background_job.save!
            flash[:error] = t("url.flash_messages.success")
          else
            job_id = UpdateUrlData.create(file: @import.csv.url,
                     bgj_id: background_job.id, type: params[:type], user_id: current_user.id,
                     promotion_id: params[:promotion_id], account_id: params[:account_id], 
                     media_id: params[:media_id], client_id: params[:client_id], 
                     media_category_id: params[:media_category_id], lang: cookies[:locale])

           background_job.job_id = job_id
           background_job.save!
           flash[:error] = t("url.flash_messages.success_update")
          end

        end

      else
        if @import.errors.messages[:csv]
          flash[:csv_error] << @import.errors.messages[:csv]
        end

        if @import.errors.messages[:csv_content_type]
          flash[:csv_error] << @import.errors.messages[:csv_content_type]
        end
        
      end
    end
    
    redirect_to url_settings_path(promotion_id: params[:promotion_id], account_id: params[:account_id])
  end

  def check_header_csv_file file_path
    flg_check_error = false
    if !File.exists?(file_path)
      message = t("error_message_url_import.unexpected_error_view")
      flg_check_error = true
    end

    current_lang = cookies[:locale]
    CSV.foreach(file_path) do |row|
      if !(row[0].to_s.strip.downcase.include? t("url.last_modified_check")) || row[1].to_s.strip.downcase != t("url.ad_id_check") || 
         row[2].to_s.strip.downcase != t("url.campaign_name_check") || row[3].to_s.strip.downcase != t("url.group_name_check") || 
         row[4].to_s.strip.downcase != t("url.ad_name_check") || row[5].to_s.strip.downcase != t("url.creative_check") || 
         row[6].to_s.strip.downcase != t("url.note_check") || row[7].to_s.strip.downcase != t("url.click_price_check") || 
         row[8].to_s.strip.downcase != t("url.url_check") || row[9].to_s.strip.downcase != t("url.redirect_url1") || 
         row[10].to_s.strip.downcase != t("url.name1") || row[11].to_s.strip.downcase != t("url.rate1") || 
         row[12].to_s.strip.downcase != t("url.redirect_url2") || row[13].to_s.strip.downcase != t("url.name2") || 
         row[14].to_s.strip.downcase != t("url.rate2") || row[15].to_s.strip.downcase != t("url.redirect_url3") || 
         row[16].to_s.strip.downcase != t("url.name3") || row[17].to_s.strip.downcase != t("url.rate3") || 
         row[18].to_s.strip.downcase != t("url.redirect_url4") || row[19].to_s.strip.downcase != t("url.name4") || 
         row[20].to_s.strip.downcase != t("url.rate4") || row[21].to_s.strip.downcase != t("url.redirect_url5") || 
         row[22].to_s.strip.downcase != t("url.name5") || row[23].to_s.strip.downcase != t("url.rate5")

         if current_lang == "en"
           I18n.locale = "ja"
         else
           I18n.locale = "en"
         end
         
         if !(row[0].to_s.strip.downcase.include? t("url.last_modified_check")) || row[1].to_s.strip.downcase != t("url.ad_id_check") || 
           row[2].to_s.strip.downcase != t("url.campaign_name_check") || row[3].to_s.strip.downcase != t("url.group_name_check") || 
           row[4].to_s.strip.downcase != t("url.ad_name_check") || row[5].to_s.strip.downcase != t("url.creative_check") || 
           row[6].to_s.strip.downcase != t("url.note_check") || row[7].to_s.strip.downcase != t("url.click_price_check") || 
           row[8].to_s.strip.downcase != t("url.url_check") || row[9].to_s.strip.downcase != t("url.redirect_url1") || 
           row[10].to_s.strip.downcase != t("url.name1") || row[11].to_s.strip.downcase != t("url.rate1") || 
           row[12].to_s.strip.downcase != t("url.redirect_url2") || row[13].to_s.strip.downcase != t("url.name2") || 
           row[14].to_s.strip.downcase != t("url.rate2") || row[15].to_s.strip.downcase != t("url.redirect_url3") || 
           row[16].to_s.strip.downcase != t("url.name3") || row[17].to_s.strip.downcase != t("url.rate3") || 
           row[18].to_s.strip.downcase != t("url.redirect_url4") || row[19].to_s.strip.downcase != t("url.name4") || 
           row[20].to_s.strip.downcase != t("url.rate4") || row[21].to_s.strip.downcase != t("url.redirect_url5") || 
           row[22].to_s.strip.downcase != t("url.name5") || row[23].to_s.strip.downcase != t("url.rate5")

           I18n.locale = current_lang
           message = I18n.t("error_message_url_import.differrent_format")
           flg_check_error = true
         end

      end

      I18n.locale = current_lang

      break
    end

    return flg_check_error, message
  end
end
