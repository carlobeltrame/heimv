module Params
  module Public
    class BookingParams < ApplicationParams
      def call(params, booking)
        permitted_params = if booking.blank? || booking.new_record?
                             self.class.permitted_create_params
                           else
                             self.class.permitted_update_params
                           end
        params = params.require(:booking).permit(*permitted_params)
        permit_values(params, booking)
        params
      end

      def self.permitted_create_params
        [:organisation, :home_id, :email,
         customer_attributes: CustomerParams.permitted_params,
         occupancy_attributes: %i[begins_at ends_at]]
      end

      def self.permitted_update_params
        [:organisation, :transition_to,
         customer_attributes: CustomerParams.permitted_params]
      end

      protected

      def permit_values(params, booking)
        return if booking.present? &&
                  BookingStateManager.new(booking).allowed_public_transitions.include?(params[:transition_to])
        params.delete(:transition_to)
      end
    end
  end
end
