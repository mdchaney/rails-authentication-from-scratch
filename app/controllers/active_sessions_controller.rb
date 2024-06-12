class ActiveSessionsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    active_session = current_user.active_sessions.find(params[:id])

    if active_session == current_active_session
      forget_active_session
      active_session.destroy
      reset_session
      redirect_to root_path, notice: "Signed out."
    else
      active_session.destroy
      redirect_to account_path, notice: "Session deleted."
    end
  end

  def destroy_all
    forget_active_session
    current_user.active_sessions.destroy_all
    reset_session

    redirect_to root_path, notice: "Signed out."
  end
end
