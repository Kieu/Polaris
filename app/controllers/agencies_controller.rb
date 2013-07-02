require 'action_view'
class AgenciesController < ApplicationController
  include ActionView::Helpers::SanitizeHelper
  before_filter :signed_in_user
  before_filter :must_super
  before_filter :get_agency, only: [:edit, :update]

  def index
  end

  def get_agencies_list
    rows = get_rows(Agency.order_by_roman_name.page(params[:page]).per(params[:rp]))
    render json: {page: params[:page], total: Agency.count, rows: rows}
  end
  
  def edit
    @prevent = "0"
  end

  def update
    @prevent = "1"
    @agency.update_user_id = current_user.id
    if @agency.update_attributes(params[:agency])
      flash[:error] = I18n.t("agency.flash_messages.update")
      redirect_to agencies_path
    else
      render :edit
    end
  end

  def new
    @agency = Agency.new
    @prevent = "0"
  end

  def create
    @prevent = "1"
    @agency = Agency.new(params[:agency])
    @agency.create_user_id = current_user.id
    @add_flg = 0
    if @agency.save
      flash[:error] = I18n.t("agency.flash_messages.success")
      redirect_to new_agency_path
    else
      @add_flg = 1
      render :new
    end
  end

  private
  def get_agency
    @agency = Agency.find(params[:id])
  end

  def get_rows agencies
    rows = Array.new
    agencies.each do |agency|
      link = view_context.link_to(view_context.image_tag("/assets/img_edit.png"),
                                  "javascript:void(0)",
                                  class: "edit",
                                  id: "edit#{index}",
                                  onclick: "ajaxCommon('#{edit_agency_path(agency)}', '', '', '','#inner')"

      )

      rows << {id: agency.id, cell: {link: link,
        roman_name: "<div title='#{sanitize(agency.roman_name)}'>" + sanitize(agency.roman_name) + "</div>",
        agency_name: "<div title='#{sanitize(agency.agency_name)}'>" + sanitize(agency.agency_name) + "</div>"}}
    end
    rows
  end
end
