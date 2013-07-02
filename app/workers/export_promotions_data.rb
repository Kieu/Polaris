# encoding: utf-8

# export promotion data table from promotion screen to csv file
class ExportPromotionsData
  include Resque::Plugins::Status
  @queue = :export_promotions

  def perform
    I18n.locale = options['language']
    # make file name
    # file name fomat: {job_id}_export_promotion_{current_date}.csv
    # get job_id
    job_id = BackgroundJob.where(id: options['bgj_id']).select('job_id').first['job_id']
    lang = options['lang']
    start_date = options['start_date']
    end_date = options['end_date']

    promotion_name = Promotion.where(id: options['promotion_id']).select("promotion_name").first['promotion_name']

    file_name = options['user_id'].to_s + "_" + promotion_name +
        "_" + Time.now.strftime("%Y%m%d_%H%M%S") + Settings.file_type.CSV
    path_file = Settings.export_promotion_path + file_name
    file_name = promotion_name + "_" + Time.now.strftime("%Y%m%d_%H%M%S") + Settings.file_type.CSV

    # initial this task
    background_job = BackgroundJob.find(options['bgj_id'])
    background_job.user_id = options['user_id']
    background_job.filename = file_name
    background_job.filepath = path_file
    background_job.breadcrumb = options['breadScrumb']
    background_job.type_view = Settings.type_view.DOWNLOAD
    background_job.status = Settings.job_status.PROCESSING
    background_job.save!

    # store csv file on server
    # path: doc/promotion_export
    array_results = Hash.new

    begin

      # get row data
      index_to_get_data_row = 0
      array_data_row = DailySummaryAccount.get_table_data(options['promotion_id'], start_date, end_date, lang)
      media = I18n.t("promotion_export_csv.media")
      account_name = I18n.t("promotion_export_csv.account_name")
      account_col = [media, account_name, "Imp", "Click", "CTR", "COST", "CPM", "CPC"]

      array_conversion = Conversion.where(promotion_id: options['promotion_id']).order('id asc')

      # initial count num
      cnt = 1

      # create csv header file
      array_conversion.each do |conversion_element|
        account_col << "CV#{cnt}"
        account_col << "CV#{cnt}(#{I18n.t("promotion_export_csv.first")})"
        account_col << "CV#{cnt}(#{I18n.t("promotion_export_csv.repeat")})"
        account_col << "CVR#{cnt}"
        account_col << "CPA#{cnt}"
        account_col << "ASSIST#{cnt}"
        account_col << "SALES#{cnt}"
        account_col << "ROAS#{cnt}"
        account_col << "PROFIT#{cnt}"
        account_col << "ROI#{cnt}"

        cnt += 1
      end

      cnt = cnt - 1
      File.open(path_file, 'wb') do |bom|
        buffer = ['EF','BB','BF'].pack("H*H*H*")
        bom.seek(0,IO::SEEK_SET)
        bom.write(buffer)
      end
      CSV.open(path_file, "a+") do |csv|

        # make header for CSV file
        csv << account_col

        # start write content of promotion to file
        media_list = Media.where(" del_flg = 0")
        account_num = 1
        media_list.each do |media|
          account_list = Account.where(" promotion_id = #{options['promotion_id']}
                                      and media_id = #{media.id}")
          .select(" id, account_name, media_id")

          account_list.each do |account|
            array_medium = Array.new
            current_data_promotion = array_data_row[index_to_get_data_row]["account#{account.id}_promotion"]
            array_medium << media.media_name
            array_medium << account.account_name
            if current_data_promotion != nil
              array_medium << current_data_promotion['imp_count'].to_s
              array_medium << current_data_promotion['click_count'].to_s
              if current_data_promotion['click_through_ratio'] == nil
                click_through_ratio = nil
              else
                click_through_ratio = current_data_promotion['click_through_ratio'].to_s + "%"
              end
              
              array_medium << click_through_ratio

              if current_data_promotion['cost_sum'] == nil
                cost_sum = nil
              else
                cost_sum = '¥' + (current_data_promotion['cost_sum'].to_s)
              end
              
              array_medium << cost_sum
              array_medium << current_data_promotion['cost_per_mille'].to_s

              if current_data_promotion['cost_per_click'] == nil
                cost_per_click = nil
              else
                cost_per_click = '¥' + (current_data_promotion['cost_per_click'].to_s)
              end

              array_medium << cost_per_click
            else
              array_medium << nil
              array_medium << nil
              array_medium << nil
              array_medium << nil
              array_medium << nil
              array_medium << nil
            end

            array_conversion.each do |conversion|
              current_data_conversion = array_data_row[index_to_get_data_row]["account#{account.id}_conversion#{conversion.id}"]
              if current_data_conversion != nil
                array_medium << current_data_conversion['total_cv_count'].to_s
                array_medium << current_data_conversion['first_cv_count'].to_s
                array_medium << current_data_conversion['repeat_cv_count'].to_s

                if current_data_conversion['conversion_rate'] == nil
                  conversion_rate = nil
                else
                  conversion_rate = current_data_conversion['conversion_rate'].to_s + "%"
                end

                array_medium << conversion_rate

                if current_data_conversion['click_per_action'] == nil
                  click_per_action = nil
                else
                  click_per_action = '¥' + (current_data_conversion['click_per_action'].to_s)
                end

                array_medium << click_per_action
                array_medium << current_data_conversion['assist_count'].to_s

                if current_data_conversion['sales'] == nil
                  sales = nil
                else
                  sales = '¥' + (current_data_conversion['sales'].to_s)
                end

                array_medium << sales
                if current_data_conversion['roas'] == nil
                  roas = nil
                else
                  roas = current_data_conversion['roas'].to_s + "%"
                end

                array_medium << roas

                if current_data_conversion['profit'] == nil
                  profit = nil
                else
                  profit = '¥' + (current_data_conversion['profit'].to_s)
                end

                array_medium << profit
                if current_data_conversion['roi'] == nil
                  roi = nil
                else
                  roi = (current_data_conversion['roi'].to_s) + "%"
                end

                array_medium << roi
              else
                array_medium << nil
                array_medium << nil
                array_medium << nil
                array_medium << nil
                array_medium << nil
                array_medium << nil
                array_medium << nil
                array_medium << nil
                array_medium << nil
                array_medium << nil
              end
            end

            csv << array_medium
          end

        end
      end

      # success case
      background_job.status = Settings.job_status.SUCCESS
      volume = File.size(path_file)
      size_field = file_size_fomat volume
      background_job.size = size_field
      background_job.save!
    rescue
      # false case
      background_job.status = Settings.job_status.WRONG
      background_job.save!
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
