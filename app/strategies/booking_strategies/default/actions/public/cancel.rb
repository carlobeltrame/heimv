module BookingStrategies
  class Default
    module Actions
      module Public
        class Cancel < BookingStrategy::Action
          def call!
            @booking.errors.clear if allowed?
            @booking.state_machine.transition_to(:cancelation_pending)
          end

          def allowed?
            @booking.state_machine.can_transition_to?(:cancelation_pending)
          end

          def button_options
            super.merge(
              class: %i[btn btn-outline-danger],
              data: {
                confirm: I18n.t(:confirm)
              }
            )
          end
        end
      end
    end
  end
end
