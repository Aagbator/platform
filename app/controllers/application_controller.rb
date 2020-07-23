require 'rubycas-server-core/tickets'
require 'dry_crud'
require 'canvas_api'

class ApplicationController < ActionController::Base
  include RubyCAS::Server::Core::Tickets
  include DryCrud::Controllers

  # before_action :authenticate_user!
  # before_action :ensure_admin!
  # after_action :remove_x_frame_options

  # skip_before_action :authenticate_user!
  # skip_before_action :ensure_admin!
  # skip_after_action :remove_x_frame_options
  
  private
  
  def authenticate_user!
    super unless authorized_by_token? || cas_ticket?
  end

  def ensure_admin!
    if current_user
      return redirect_to(CanvasAPI.client.canvas_url) if current_user.canvas_id && !current_user.admin?
      return redirect_to('/unauthorized') unless current_user.admin?
    end
  end
  
  def authorized_by_token?
    return false unless request.format.symbol == :json

    key = params[:access_key] || request.headers['Access-Key']
    return false if key.nil?
    
    !!AccessToken.find_by(key: key)
  end

  def cas_ticket?
    ticket = params[:ticket]
    return false if ticket.nil?

    ServiceTicket.exists?(ticket: ticket)
  end

  # This is defined by :database_authenticable on the User model, but we're using :cas_authenticatable
  # However, we still want to support account creation, registration, and confirmation which is 
  # database_authenticable functionality so we need to define this for those built-in views to work.
  def new_session_path(_)
    new_user_session_path
  end
  helper_method :new_session_path

  def canvas_url
    CanvasAPI.client.canvas_url
  end
  helper_method :canvas_url

  # This is just the main login path that redirects to the proper place on success.
  # e.g. https://platform.bebraven.org/cas/login?service=https%3A%2F%2Fportal.bebraven.org%2Flogin%2Fcas
  def cas_login_url
    ::Devise.cas_client.add_service_to_login_url(::Devise.cas_service_url(request.url, devise_mapping))
  end
  helper_method :cas_login_url

  # Remove the default X-Frame-Options header Rails adds. We use CSP instead.
  # See config/initializers/content_security_policy.rb
  # Technically, CSP should take precedence anyway, but this is down to browser implementation, so
  # better to not take chances.
  def remove_x_frame_options
    response.headers.delete "X-Frame-Options"
  end
end
