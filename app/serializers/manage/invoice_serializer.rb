module Manage
  class InvoiceSerializer < ApplicationSerializer
    DEFAULT_INCLUDES = 'booking.occupancy,booking.tenant,booking.home'.freeze

    belongs_to :booking, serializer: Manage::BookingSerializer

    attributes :invoice_type, :text, :issued_at, :payable_until, :esr_number
  end
end