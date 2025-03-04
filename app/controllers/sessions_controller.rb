class SessionsController < ApplicationController
  before_action :current_user
  before_action :update_activity_time
  before_action :session_expiry, except: [:create]

  def new

  end

  def create

    email = params[:email]
    password = params[:password]

    @user = User.find_by_email(email)

    if @user && @user.authenticate(password)
      session[:user_id] = @user.id
      puts request.referrer
      redirect_to(root_path, notice: "Welcome to Milieu")
      # (request.referrer == new_session_path) ? redirect_to(root_path, notice: "Welcome to Milieu") : redirect_to(request.referrer, notice: "Welcome to Milieu")
    else
      redirect_to new_session_path, alert: "Could not sign in, try again"
    end

  end

  def destroy
    logout
  end

  private

      def update_activity_time
        session[:expires_at] = 24.hours.from_now
      end

      def session_expiry
        get_session_time_left
        disconnect_user if @session_time_left <= 0
      end

      def logout
        disconnect_user
        redirect_to root_path, notice: "Logged out"
      end

      def disconnect_user
        session[:user_id] = nil
        cookies.delete(:user_id)
        @current_user = nil
      end

      def get_session_time_left
        expire_time = session[:expires_at] || Time.now
        @session_time_left = (expire_time.to_time - Time.now).to_i
      end

end
