class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery
  unless  Rails.application.config.consider_all_requests_local
    rescue_from ActionController::RoutingError, with: :redirect_to_404
    rescue_from ActionController::UnknownController, with: :redirect_to_404
    rescue_from ActionController::UnknownAction, with: :redirect_to_404
    rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_404
    rescue_from ActionView::MissingTemplate, with: :redirect_to_404
    rescue_from Mysql2::Error, with: :render_500
  end
  include SessionsHelper

  before_filter :set_locale
  before_filter :set_notify

  def signed_in_user
    redirect_to signin_url, notice: "Please sign in." unless signed_in?
  end
  
  def must_super
    redirect_to root_path unless current_user.super?
  end

  def must_super_agency
    redirect_to promotions_path if current_user.client?
  end
  
  def set_notify
    return unless current_user
    @notify = BackgroundJob.where(user_id: current_user.id, status: '0').size
  end

  private
  def set_locale
    I18n.locale = cookies[:locale] || I18n.default_locale
    cookies[:locale] = I18n.locale.to_s 
  end

  def redirect_to_404
    redirect_to '/public/404.html', status: '302'
  end

  def render_500
    render file: 'public/500.html', status: :not_found
  end

  # convert integer to 36 decimal
  def make_mpv media_category_id, promotion_id, account_id, redirect_infomation_id
    account_id = account_id.to_s(36)
    promotion_id = promotion_id.to_s(36)
    
    media_category_id = media_category_id.to_s(36)
    redirect_infomation_id = redirect_infomation_id.to_s(36)

    mpv = medisa_category_id + "." + promotion_id + "." + account_id + "." + redirect_infomation_id
    return mpv
  end

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
