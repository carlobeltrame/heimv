# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    load_and_authorize_resource :user

    def index
      respond_with :admin, @users
    end

    def show
      respond_with :admin, @user
    end

    def edit
      respond_with :admin, @user
    end

    def new
      respond_with :admin, @user
    end

    def create
      @user.password = params.dig(:user, :password).presence
      @user.save
      respond_with :admin, @user
    end

    def update
      @user.password = params.dig(:user, :password).presence
      @user.update(user_params)
      respond_with :admin, @user
    end

    def destroy
      @user.destroy
      respond_with :admin, @user, location: admin_users_path
    end

    private

    def user_params
      UserParams.new(params.require(:user)).permitted
    end
  end
end
