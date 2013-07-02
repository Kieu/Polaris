module SessionsHelper
  def sign_in user
    user.save
    user.remove_block_login if user.block_login_user
    session[:user_id] = user.id
    self.current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  def sign_out
    session.delete :user_id
    self.current_user = nil
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user?(user)
    user == current_user
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end

  def cal_col_cv conversion_id
    count = 0
    cookies[("conversion" + conversion_id.to_s).to_sym].split("").each do |i|
      count += 1 if i == "1"
    end
    count
  end

  def cal_cv conversion_id
    count = 0
    cookies[("conversion" + conversion_id.to_s).to_sym].split("").each_with_index do |i, index|
      count += 1 if i == "1"
    end
    count
  end
end