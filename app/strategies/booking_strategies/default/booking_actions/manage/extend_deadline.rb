module BookingStrategies
  class Default
    module BookingActions
      class Manage
        class ExtendDeadline < BookingStrategy::BookingAction
          def call!
            case @booking.current_state.to_sym
            when :provisional_request
              @booking.deadline.extend_until(14.days.from_now)
            when :overdue_request
              @booking.state_machine.transition_to(:provisional_request)
            when :payment_overdue
              @booking.state_machine.transition_to(:payment_due)
            end
          end

          def allowed?
            @booking.deadline&.extendable?
          end

          def variant
            :'outline-primary'
          end
        end
      end
    end
  end
end