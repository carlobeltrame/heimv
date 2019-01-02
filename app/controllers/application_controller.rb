class ApplicationController < ActionController::Base
  responders :flash, :http_cache
  respond_to :html, :json

  protect_from_forgery with: :exception
  rescue_from CanCan::AccessDenied, with: :unauthorized
  before_action :set_organisation
  before_action :configure_permitted_parameters, if: :devise_controller?
  default_form_builder BootstrapForm::FormBuilder

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def current_organisation
    @organisation
  end

  private

  def set_organisation
    @organisation = Organisation.find_by(ref: params[:org])
  end

  def unauthorized
    if current_user.nil?
      session[:next] = request.fullpath
      redirect_to login_url, alert: 'You have to log in to continue.'
    else
      render text: 'oops!', status: :forbidden
    end
  end
end
