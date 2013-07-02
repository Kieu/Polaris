class SessionsController < ApplicationController
  before_filter :prevent_double_login, only: [:new, :create]

  def new
    @press_release = PressRelease.order("id DESC").first(7)
  end

  def create
    @errors = Array.new
    @press_release = PressRelease.order("id DESC").first(7)
    user = User.find_by_email(params[:session][:email])
    if user
      if user.can_login?
        if user.authenticate(params[:session][:password])
          flash[:success] = "Welcome to Canpass"
          sign_in user
          cookies[:locale] = params[:language]
          if user.role_id == Settings.role.CLIENT
            redirect_to promotions_path
          else
            redirect_to clients_path
          end
        else
          user.update_login_fail
          @errors << I18n.t("login.unsuccessfull")
          render :new
        end
      else
        if user.status == Settings.user.deactive
          @errors << I18n.t("login.deactive")
        else
          @errors << I18n.t("login.block")
        end
        render :new
      end
    else
      @errors << I18n.t("login.unsuccessfull")
      render :new
    end
  end

  def signout
    sign_out
    redirect_to root_url
  end

  def resend_password
    @press_release = PressRelease.order("id DESC").first(7)
    @form_errors = Array.new
    if params[:email].to_s.strip.length == 0
      flash.now[:email_empty] = I18n.t("login.email_empty")
      render :new
      return
    end
    user = User.find_by_email(params[:email])
    @email = params[:email]
    if verify_recaptcha
      if user
        user.password = SecureRandom.urlsafe_base64(6)
        user.save
        job_id = SendMail.create(user: user, password: user.password)
        flash[:send_success] = I18n.t("login.send_success")
        redirect_to signin_path
      else
        @form_errors << I18n.t("login.captcha_email_not_found")
        render :new
      end
    else
      @form_errors << I18n.t("login.captcha_error")
      render :new
    end
  end
  
  private
  
  def prevent_double_login
    redirect_to root_path if current_user
  end
end
