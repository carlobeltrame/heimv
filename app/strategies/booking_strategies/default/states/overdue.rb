# frozen_string_literal: true

module BookingStrategies
  class Default
    module States
      class Overdue < BookingStrategy::State
        def checklist
          [
            ChecklistItem.new(:deposit_paid, Invoices::Deposit.of(booking).relevant.all?(&:paid),
                              [:manage, booking, Invoice]),
            ChecklistItem.new(:contract_signed, booking.contracts.signed.exists?, [:manage, booking, Contract])
          ]
        end

        def self.to_sym
          :overdue
        end

        def relevant_time
          booking.deadline&.at
        end
      end
    end
  end
end
