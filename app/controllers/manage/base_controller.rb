# frozen_string_literal: true

module Manage
  class BaseController < ApplicationController
    before_action :authenticate_user!
    check_authorization

    protected

    def current_ability
      @current_ability ||= Ability::Manage.new(current_user)
    end

    def current_organisation
      @current_organisation ||= if current_user.role_admin?
                                  Organisation.find_by(slug: params[:org])
                                else
                                  current_user.organisation
                                end
    end
  end
end
