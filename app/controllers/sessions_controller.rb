# frozen_string_literal: true

class SessionsController < ApplicationController
  def new; end

  def create; end

  def destroy
    reset_session
    redirect_to root_url
  end

  def omniauth_callback
    omniauth_data = omniauth_info
    user = Teacher.user_from_omniauth(omniauth_data)
    if user.present?
      user.last_session_at = Time.zone.now
      user.try_append_ip(request.remote_ip)
      user.session_count += 1
      user.save!
      log_in(user)
    else
      Sentry.capture_message("OAuth Login Failure")
      session[:auth_data] = omniauth_data
      flash[:alert] = "We couldn't find an account for #{omniauth_data.email}. Please submit a new request."
      redirect_to new_teacher_path
    end
  end

  def omniauth_info
    request.env["omniauth.auth"].info
  end

  def omniauth_failure
    redirect_to root_url,
                alert: "Login failed unexpectedly. Please reach out to contact@bjc.berkeley.edu"
  end
end
