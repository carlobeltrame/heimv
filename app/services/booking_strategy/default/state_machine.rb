module BookingStrategy
  module Default
    class StateMachine < Base::StateMachine
      state :initial, initial: true
      STATES = %i[
        new_request provisional_request definitive_request overdue_request cancelled
        confirmed upcoming overdue active past payment_due payment_overdue completed
      ].freeze
      STATES.each { |s| state(s) }

      PUBLIC_TRANSITIONS = %w[
        new_request provisional_request definitve_request cancelled
      ].freeze

      PREFERED_TRANSITIONS = {
        initial: :new_request,
        new_request: :provisional_request,
        provisional_request: :definitive_request,
        definitive_request: :confirmed,
        overdue_request: :confirmed,
        confirmed: :upcoming,
        overdue: :upcoming,
        upcoming: :active,
        active: :past,
        past: :payment_due,
        payment_due: :completed,
        payment_overdue: :completed
      }.with_indifferent_access.freeze

      transition from: :initial, to: %i[new_request provisional_request definitive_request]
      transition from: :overdue_request, to: %i[cancelled definitive_request provisional_request]
      transition from: :new_request, to: %i[cancelled provisional_request definitive_request]
      transition from: :provisional_request, to: %i[definitive_request overdue_request cancelled]
      transition from: :definitive_request, to: %i[cancelled confirmed]
      transition from: :confirmed, to: %i[cancelled upcoming overdue]
      transition from: :overdue, to: %i[cancelled upcoming]
      transition from: :upcoming, to: %i[cancelled active]
      transition from: :active, to: %i[past]
      transition from: :past, to: %i[payment_due]
      transition from: :payment_due, to: %i[payment_overdue completed]
      transition from: :payment_overdue, to: %i[completed]

      guard_transition(to: %i[provisional_request definitive_request]) do |booking|
        # booking.customer.complete?
      end

      guard_transition(to: :upcoming) do |_booking|
        true
        # booking.contracts.any? &&
        #   booking.contracts.all?(&:signed?) &&
        #   booking.bills.deposits.all?(&:payed_or_prolonged?)
      end

      guard_transition(to: :completed) do |_booking|
        true
        # booking.bills.any? &&
        #   booking.bills.open.none?
      end

      guard_transition(to: :cancelled) do |_booking|
        true
        # booking.bills.open.none?
      end

      after_transition(to: %i[new_request]) do |booking|
        BookingNotificationService.new(booking).confirm_request_notification
      end

      after_transition(to: %i[cancelled]) do |booking|
        booking.occupancy.update(blocking: false)
      end

      after_transition(to: %i[confirmed upcoming active overdue]) do |booking|
        booking.occupancy.update(blocking: true)
      end

      # automatic_transition(from: :new_request, to: :p)
    end
  end
end
