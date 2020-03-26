module SessionsHelper
  def current_user? user
    user && current_user == user
  end

  def redirect_back_or default
    redirect_to session[:forwarding_url] || default
    session.delete :forwarding_url
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  def email? string
    Settings.user.email_regex === string
  end
end
