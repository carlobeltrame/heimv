# frozen_string_literal: true

module Manage
  class BookingsController < BaseController
    load_and_authorize_resource :booking
    before_action :set_filter, only: :index

    if defined?(NewRelic)
      include ::NewRelic::Agent::MethodTracer
      add_method_tracer :update
    end

    def index
      @bookings = @filter.apply(@bookings.with_default_includes.ordered)
      @grouped_bookings = group_bookings(@bookings)
      respond_with :manage, @bookings
    end

    def show
      respond_with :manage, @booking
    end

    def new
      @booking.organisation = current_organisation
      @booking.build_occupancy
      @booking.build_tenant
      respond_with :manage, @booking
    end

    def edit; end

    def create
      @booking.organisation = current_organisation
      @booking.transition_to ||= current_organisation.booking_strategy.manually_created_bookings_transition_to
      @booking.save
      respond_with :manage, @booking
    end

    def update
      @booking.update(booking_params) if booking_params
      call_booking_action
      respond_with :manage, @booking
    end

    def destroy
      @booking.destroy
      respond_with :manage, @booking, location: manage_bookings_path
    end

    private

    def set_filter
      @filter = Booking::Filter.new(default_booking_filter_params.merge(booking_filter_params))
    end

    def call_booking_action
      booking_action&.call(booking: @booking)
    rescue BookingStrategy::Action::NotAllowed
      @booking.errors.add(:base, :action_not_allowed)
    end

    def booking_action
      current_organisation.booking_strategy.manage_actions[params[:booking_action]]
    end

    def booking_params
      BookingParams.new(params[:booking])
    end

    def booking_filter_params
      Manage::BookingFilterParams.new(params)
    end

    def default_booking_filter_params
      { 'current_booking_states' => current_organisation.booking_strategy.displayed_booking_states }
    end

    def group_bookings(bookings)
      bookings.group_by(&:state).sort_by do |state, _bookings|
        current_organisation.booking_strategy.state_machine.states.index(state)
      end
    end
  end
end
