require 'csv'

# export promotion data table from promotion screen to csv file
class ExportUrlData
  include Resque::Plugins::Status
  @queue = :export_url

  def perform
    # make file name
    account_name = Account.where(id: options['account_id']).select("roman_name").first['roman_name']
    promotion_obj = Promotion.where(id: options['promotion_id']).select("roman_name, client_id")
    promotion_name = promotion_obj.first['roman_name']
    client_id = promotion_obj.first['client_id']
    # file name fomat: {account_romaji_name}_export_url_{current_date}.csv
    file_name = options['user_id'].to_s + "_" + Settings.EXPORT_URL +
      "_" + Time.now.strftime("%Y%m%d") + Settings.file_type.CSV
    path_file = Settings.export_url_path + file_name
    file_name = promotion_name.to_s + "_" + account_name.to_s + "_" + Time.now.strftime("%Y%m%d") + Settings.file_type.CSV

    # initial this task
    background_job = BackgroundJob.find(options['bgj_id'])
    background_job.user_id = options['user_id']
    background_job.filename = file_name
    background_job.filepath = path_file
    background_job.breadcrumb = options['breadcrumb']
    background_job.type_view = Settings.type_view.DOWNLOAD
    background_job.status = Settings.job_status.PROCESSING
    background_job.save!
    begin
      url_data = Array.new
      total_row = Array.new
      url_data, total_row = RedirectUrl.get_url_data(options['promotion_id'], options['account_id'],
        options['media_id'], nil, nil, options['start_date'], options['end_date'], 'download')
      
      File.open(path_file, 'wb') do |bom|
        buffer = ['EF','BB','BF'].pack("H*H*H*")
        bom.seek(0,IO::SEEK_SET)
        bom.write(buffer)
      end
      
      CSV.open(path_file, "a+") do |csv|
        csv << ["Export Url data"]
        csv << ["Time range: #{options['start_date']} - #{options['end_date']}"]
        csv << [""]
        csv << [""]
        csv << options['array_header_csv']
        url_data.each do |url|
          array_date_csv = Array.new
          array_date_csv << url['last_modified']
          array_date_csv << url['ad_id']
          array_date_csv << url['campaign_name']
          array_date_csv << url['group_name']
          array_date_csv << url['ad_name']
          array_date_csv << url['creative_id']
          submit_url = Settings.DOMAIN_SUBMIT_URL + "mpv=#{url['mpv']}" + "&cid=#{client_id}&pid=#{options['promotion_id']}"
          array_date_csv << submit_url
          array_date_csv << url['comment']
          array_date_csv << url['click_unit']

          # get redirect URL
          array_redirect_url = RedirectUrl.where(mpv: url['mpv']).select('url, name, rate')
          array_redirect_url.each do |redirect_url|
            array_date_csv << redirect_url.url
            array_date_csv << redirect_url.name
            array_date_csv << redirect_url.rate
          end
          
          csv << array_date_csv
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
