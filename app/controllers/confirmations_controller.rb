class ConfirmationsController < ApplicationController
  before_action :redirect_if_authenticated, only: [:create, :new]

  def create
    @user = User.find_by(email: params[:user][:email].downcase)

    if @user.present? && @user.unconfirmed?
      @user.send_confirmation_email!
      redirect_to root_path, notice: "Check your email for confirmation instructions."
    else
      redirect_to new_confirmation_path, alert: "We could not find a user with that email or that email has already been confirmed."
    end
  end

  def edit
    expected_email = params[:email].strip.downcase

    # It's possible that the email address that we're confirming is the 
    # primary "email" field or the secondary "unconfirmed_email" field.
    # We need to check both fields to find the user, but will only check
    # the primary field if the secondary field is null.
    @user = (User.where(unconfirmed_email: expected_email).
               or(User.where(email: expected_email, unconfirmed_email: nil))).
        find_signed(params[:confirmation_token],
                    purpose: User.email_confirmation_purpose_for(expected_email))
    if @user.present? && @user.unconfirmed_or_reconfirming?
      if @user.confirm!
        login @user
        redirect_to root_path, notice: "Your account has been confirmed."
      else
        redirect_to new_confirmation_path, alert: "Something went wrong."
      end
    else
      redirect_to new_confirmation_path, alert: "Invalid token."
    end
  end

  def new
    @user = User.new
  end
end
