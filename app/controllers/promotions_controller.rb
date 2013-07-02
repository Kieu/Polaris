require "resque"
class PromotionsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency, except: [:index, :change_data, :download_csv]
  before_filter :must_right_object, only: [:edit, :update, :delete_promotion,
    :index, :new, :create]

  def index
    if @array_promotion.length > 0
      @promotion = @array_promotion.find(@promotion_id)
      @start_date = params[:start_date].present? ? params[:start_date] :
        Date.yesterday.at_beginning_of_month.strftime(I18n.t("time_format"))
      @end_date = params[:end_date].present? ? params[:end_date] :
        Date.yesterday.strftime(I18n.t("time_format"))
      cookies[:promotion] = "111111" unless cookies[:promotion].present?
      @conversions = @promotion.conversions.order_by_id
      @conversions.each do |conversion|
        cookies[("conversion" + conversion.id.to_s).to_sym] = "1111111111" unless
          cookies[("conversion" + conversion.id.to_s).to_sym].present?
      end
      @client_name = @client.client_name
      @promotion_name = @promotion.promotion_name
        
      @media_list = Media.get_media_list
      @account_list = Account.get_account_list(@promotion_id, @media_list)
        
      @promotion_results, @promotion_data, @array_category = DailySummaryAccount
        .get_table_data(@promotion_id, @start_date, @end_date)
  
      @select_left = params[:left].present? ? params[:left] : "COST"
      @select_right = params[:right].present? ? params[:right] : "click"
    end
  end

  def new
    @promotion = Promotion.new
    @prevent = "0"
  end

  def create
    @promotion = Promotion.new(params[:promotion])
    @prevent = "1"
    @promotion.create_user_id = current_user.id
    @promotion.client_id = params[:client_id]
    if @promotion.save
      flash[:error] = I18n.t("promotion.flash_messages.success")
      redirect_to new_promotion_path(client_id: params[:client_id])
    else
      @client = Client.find(params[:client_id])
      render :new
    end
  end

  def edit
    @prevent = "0"
    @promotion = @array_promotion.find(params[:id])
    params[:promotion_id] = params[:id]
    @promotion_id = params[:id]
    @promotion_name = @promotion.promotion_name
  end

  def update
    @prevent = "1"
    @promotion = @array_promotion.find(params[:id])
    @promotion_id = params[:id]
    params[:promotion_id] = params[:id]
    @promotion_name = params[:promotion_name]
    @promotion.update_user_id = current_user.id
    if @promotion.update_attributes(params[:promotion])
      flash[:error] = I18n.t("promotion.flash_messages.update")
      redirect_to promotions_path(client_id: @promotion.client_id)
    else
      render :edit
    end
  end

  def delete_promotion
    @promotion = @array_promotion.find(params[:promotion_id])
    @promotion.delete
    render text: "ok"    
  end
  
  def change_data
    results = Hash.new
    @client_id = params[:client_id]
    @promotion_id = params[:promotion_id]
    @promotion = Promotion.find(@promotion_id)
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    
    @client_name = Client.find(@client_id).client_name
    @promotion_name = @promotion.promotion_name
    @conversions = @promotion.conversions.order_by_id
        
    @media_list = Media.get_media_list
    @account_list = Account.get_account_list(@promotion_id, @media_list)
        
    @promotion_results, @promotion_data, date_arrange = DailySummaryAccount
        .get_table_data(@promotion_id, @start_date, @end_date)
    
    results[:promotion_data] = @promotion_data
    
    results[:array_category] = date_arrange
    
    results[:html] = render_to_string "promotions/promotion_table", layout: false
    respond_to do |format|
      format.json{render json: results}
    end
  end

  def download_csv
    start_date = params[:start_date]
    end_date = params[:end_date]
    breadScrumb = params[:client_name] + ">" + params[:promotion_name]
    if  !start_date || !end_date
      start_date = Date.yesterday.at_beginning_of_month.strftime(I18n.t("time_format"))
      end_date = Date.yesterday.strftime(I18n.t("time_format"))
    end

    promotion_id = params[:promotion_id].to_i
    user_id = current_user.id
    background_job = BackgroundJob.create
    background_job.user_id = user_id 
    background_job.type_view = Settings.type_view.DOWNLOAD
    background_job.status = Settings.job_status.PROCESSING
    background_job.breadcrumb = breadScrumb
    background_job.save!

    job_id = ExportPromotionsData.create(user_id: user_id,
             promotion_id: promotion_id, breadScrumb: breadScrumb, bgj_id: background_job.id, start_date: start_date,
             end_date: end_date, lang: I18n.t("time_format"), language: cookies[:locale])
    
    background_job.job_id = job_id
    background_job.save!
    
    render text: "processing"
  end
  
  def promotion_table
  end

  private
  def must_right_object
    if current_user.client?
      @client_id = current_user.company_id  
    else
      @client_id = params[:client_id]
    end
    @client = Client.find(@client_id)    
    if current_user.agency? && !@client.client_users.find_by_user_id(current_user.id)
      redirect_to clients_path
    end
    @array_promotion = @client.promotions.active.order_by_roman_name
    #redirect_to clients_path if @array_promotion.length == 0 && current_user.super? 
    if @array_promotion.length > 0
      @promotion_id = params[:promotion_id].blank? ? @array_promotion.first[:id] :
        params[:promotion_id]
    end
  end
end
