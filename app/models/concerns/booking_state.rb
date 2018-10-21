require 'active_support/concern'

module BookingState
  extend ActiveSupport::Concern

  delegate :current_state, to: :state_machine

  included do
    attr_accessor :transition_to, :skip_automatic_transition
    has_many :booking_transitions, dependent: :destroy, autosave: false

    after_save :state_transition
    after_touch :state_transition

    validate do
      if transition_to.present? && !state_machine.can_transition_to?(transition_to)
        errors.add(:transition_to,
                   I18n.t(:'activerecord.errors.models.booking.attributes.state.invalid_transition',
                          transition: "#{state_was}-->#{state}"))
      end
    end
  end

  def booking_strategy
    @booking_strategy ||= BookingStrategy.infer(self)
  end

  def state_machine
    @state_machine ||= booking_strategy::StateMachine.new(self)
  end

  def state_machine_automator
    @state_machine_automator ||= booking_strategy::StateMachineAutomator.new(state_machine)
  end

  def state_transition
    state_machine.transition_to(transition_to) if state_machine.current_state != transition_to
    Rails.logger.info state_machine_automator.run unless skip_automatic_transition
  end
end
