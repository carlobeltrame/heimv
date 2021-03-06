# frozen_string_literal: true

module Admin
  class OrganisationParams < Manage::OrganisationParams
    def self.permitted_keys
      super + %i[booking_strategy_type invoice_ref_strategy_type notifications_enabled smtp_url slug]
    end
  end
end
