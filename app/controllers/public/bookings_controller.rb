module Public
  class BookingsController < BaseController
    load_and_authorize_resource :booking
    before_action :initialize_view_model

    def new
      @booking.build_occupancy
      @booking.occupancy.begins_at = Time.zone.now.change(hour: 11, min: 0, sec: 0)
      @booking.occupancy.ends_at = (@booking.occupancy.begins_at + 7.days).change(hour: 17)
      respond_with :public, @booking
    end

    def edit
      respond_with :public, @booking
    end

    def create
      @booking.save
      respond_with :public, @booking, location: root_path
    end

    def update
      @booking.strict_validation = true
      @booking.update(update_params)
      respond_with :public, @booking, location: edit_public_booking_path
    end

    private

    def initialize_view_model
      @view_model = @booking.booking_strategy::ViewModel.new(@booking)
    end

    def booking_params
      BookingParams::Create.permit(params[:booking])
    end

    def update_params
      BookingParams::Update.permit(params.require(:booking))
    end
  end
end
