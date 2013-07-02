class AccountsController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super_agency
  before_filter :must_right_object, only: [:edit, :update]
  def new
    @account = Account.new
    @prevent = "0"
    @account.margin = Settings.account_cost_default
    @promotion_id = params[:promotion_id]
    @promotion = Promotion.find_by_id(@promotion_id)
    @medias = Media.active.where(media_category_id: 1)
    @client_id = @promotion.client.id
  end
  
  def edit
    @prevent = "0"
    @account = Account.find(params[:id])
    @account_name = Account.find(params[:id]).account_name
    @promotion_id = params[:promotion_id]
    @promotion = Promotion.find_by_id(@promotion_id)
    @client_id = @promotion.client.id
    @account_id = params[:id]
  end
  def update
    @prevent = "1"
    @account = Account.find(params[:id])
    @promotion_id = params[:promotion_id]
    @promotion = Promotion.find_by_id(@promotion_id)
    @client_id = @promotion.client.id
    @account.attributes = params[:account]
    @account.update_user_id = current_user.id
    if @account.sync_flg.to_i == 1
      @account.sync_account_id = nil
      @account.sync_account_pw = nil
    end
    if @account.valid?
      ActiveRecord::Base.transaction do
        if @account.sync_account_pw != nil
          @account.sync_account_pw = AESCrypt.encrypt("TOPSCERETPOLARIS", @account.sync_account_pw)
        end
        if @account.save
          @margin = MarginManagement.new
          time = Time.new
          @margin.report_ymd = "#{time.year}#{time.month}#{time.day}"
          @margin.account_id = @account.id
          @margin.margin_rate = @account.margin
          @margin.create_user_id = current_user.id
          @margin.update_user_id = current_user.id
          if !@margin.save        
            flash[:error] = I18n.t("account.flash_messages.success_error")
            raise ActiveRecord::Rollback
          end
        end
      end
    else
      flash[:error] = I18n.t("account.flash_messages.success_error")
    end
    if flash[:error]
      @account_name = Account.find(params[:id]).account_name
      render :edit
    else
      flash[:error] = I18n.t("account.flash_messages.update")
      redirect_to promotions_path(promotion_id: @promotion_id, client_id: @promotion.client.id)
    end
  end
  def create
    @prevent = "1"
    @account = Account.new(params[:account])
    @medias = Media.active.where(media_category_id: @account.media_category_id)
    @promotion_id = params[:promotion_id]
    #get promotion by id
    @promotion = Promotion.find_by_id(@promotion_id)
    @client_id = @promotion.client_id
    @account.create_user_id = current_user.id
    if @account.sync_flg.to_i == 1
      @account.sync_account_id = nil
      @account.sync_account_pw = nil
    end
    
    if @account.valid?
      if @account.sync_account_pw != nil
        @account.sync_account_pw = AESCrypt.encrypt("TOPSCERETPOLARIS", @account.sync_account_pw)
      end
      ActiveRecord::Base.transaction do
        if @account.save
          @margin = MarginManagement.new
          time = Time.new
          @margin.report_ymd = "#{time.year}#{time.month}#{time.day}"
          @margin.account_id = @account.id
          @margin.margin_rate = @account.margin
          @margin.create_user_id = current_user.id
          if !@margin.save        
            flash[:error] = I18n.t("account.flash_messages.success_error")
            raise ActiveRecord::Rollback
          end
        end
      end
      if flash[:error]
        @account.media_id = params[:account][:media_id]
        render "new", promotion_id: @promotion_id
      else
        flash[:error] = I18n.t("account.flash_messages.success")
        redirect_to promotions_path(promotion_id: @promotion_id, client_id: @promotion.client_id)
      end
    else
      render "new", promotion_id: @promotion_id
    end
  end
  
  def change_medias_list
    render json: Media.active.where(media_category_id: params[:cid])
  end
  
  private
  def must_right_object
    @account = Account.find(params[:id])
    if current_user.agency? && !@account.promotion.client.client_users.find_by_user_id(current_user.id)
      redirect_to promotions_path(promotion_id: params[:promotion_id], client_id: @account.promotion.client.id)
    end
  end
end
