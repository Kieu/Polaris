class ConversionsController < ApplicationController
  
  before_filter :signed_in_user
  before_filter :must_super_agency
  before_filter :get_promotion, only: [:index, :new, :create, :edit, :update, :get_tag]
  before_filter :get_conversion, only: [:edit, :update, :get_tag]
  before_filter :get_list_conversions
  
  def index
  end

  def new
    @conversion = Conversion.new
    @conversion.session_period = Settings.conversion_session_period_default
    @current_id = 1
    @prevent = "0"
  end

  def create
    @conversion = Conversion.new(params[:conversion])
    @conversion.create_user_id = current_user.id
    @conversion.promotion_id = params[:promotion_id]
    conversion_combine = ''
    @prevent = "1"
    has_error = 0
    if params[:cv] && params[:cv].count > 0
      check_valid = Hash.new 
      params[:cv].each_with_index do |op, idx|
        if params[:cv][idx].to_i > 0
          if check_valid[params[:cv][idx]]
            flash[:combine_error] = t("conversion.flash_messages.existed")
            has_error = 1
          else
            check_valid.store(params[:cv][idx], '1')
          end
          if idx == 0
            if params[:cv][idx].present?
              conversion_combine << "#{params[:cv][idx]}_#{params[:cv_kind][idx]}"
            end
          else
            if params[:cv][idx].present?
              conversion_combine << "|#{params[:op][idx - 1]}|#{params[:cv][idx]}_#{params[:cv_kind][idx]}"
            end
          end
         end   
      end
    end
    @conversion.conversion_combine = conversion_combine
    if @conversion.save
      @conversion.create_mv
      flash[:error] = t("conversion.flash_messages.success")
    else
      has_error = 1
    end
    if has_error == 1
      if @conversion.conversion_combine.present?
          @cv_list = Hash.new
          @cv_kind_list = Hash.new
          @op_list = Hash.new
          conversions = Conversion.where(promotion_id: params[:promotion_id]).select("id, conversion_name")
          if params[:cv].count > 0
            idx = 0
            params[:cv].each do | cv |
              if cv.to_i > 0 
                @cv_list[idx] = {"id" => cv, "name" => conversions.find(cv.to_i).conversion_name}
                
                @cv_kind_list[idx] = {"id" => params[:cv_kind][idx], "name" => t(Settings.conversion_kind[params[:cv_kind][idx].to_i])}
              else
                @cv_list[idx] = {"id" => '', "name" => ''}
                
                @cv_kind_list[idx] = {"id" => '', "name" => ''}
              end
              idx += 1
            end
            @op_list = params[:op]
          end 
      end
      render :new
    else
      redirect_to conversions_path(promotion_id: params[:promotion_id])
    end
  end

  def edit
    @prevent = "0"
    if (@conversion.conversion_combine.present?)
      combine = @conversion.conversion_combine.split('|')
      @cv_list = Hash.new
      @cv_kind_list = Hash.new
      @op_list = Hash.new
      conversions = Conversion.where(promotion_id: params[:promotion_id]).select("id, conversion_name")
      combine.each_with_index do |v, idx|
        if idx % 2 == 0
          cv = v.split('_')
          @cv_list[idx/2] = {"id" => cv[0], "name" => conversions.find(cv[0].to_i).conversion_name}
          @cv_kind_list[idx/2] = {"id" => cv[1], "name" => I18n.t(Settings.conversion_kind[cv[1].to_i])}
        else
          @op_list[idx/2] = v
        end
      end  
    end
  end

  def update
    conversion_combine = ''
    @prevent = "1"
    if params[:cv] && params[:cv].count > 0
      params[:cv].each_with_index do |op, idx|
        if idx == 0
          if params[:cv][idx].present?
            conversion_combine << "#{params[:cv][idx]}_#{params[:cv_kind][idx]}"
          end
        else
          if params[:cv][idx].present?
            conversion_combine << "|#{params[:op][idx - 1]}|#{params[:cv][idx]}_#{params[:cv_kind][idx]}"
          end
        end   
      end
    end
    @conversion.conversion_combine = conversion_combine
    @conversion.update_user_id = current_user.id
    @conversion.attributes = params[:conversion]
    
    if @conversion.save
      flash[:error] = t("conversion.flash_messages.update")
      redirect_to conversions_path(promotion_id: @conversion.promotion_id)
    else
      render :edit
    end
  end

  def get_tag
  end
  
  def change_current_id
    if !@current_id
      @current_id = 1
    else
      @current_id+=1
    end
  end
  private
  def get_promotion
    @promotion = Promotion.find(params[:promotion_id])
  end

  def get_conversion
    @conversion = Conversion.find(params[:id])
    @conversion_name = @conversion.conversion_name.present? ?
      @conversion.conversion_name : params[:conversion_name]
  end
  
  
  def get_list_conversions
    @conversions = params[:promotion_id].blank? ? Array.new :
      Conversion.get_by_promotion_id(params[:promotion_id]).
      order_by_roman_name.select("id, conversion_name")
  end
end
