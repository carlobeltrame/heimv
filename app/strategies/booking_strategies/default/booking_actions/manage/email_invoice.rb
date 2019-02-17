module BookingStrategies
  class Default
    module BookingActions
      class Manage
        class EmailInvoice < BookingStrategy::BookingAction
          def call!(invoices = @booking.invoices.unsent)
            @booking.messages.new_from_template(:payment_overdue_message)&.deliver_now do |message|
              message.attachments.attach(invoices.map { |invoice| invoice.pdf.blob })
            end && invoices.each(&:sent!)
          end

          def allowed?
            @booking.invoices.unsent.any? && !@booking.state_machine.in_state?(:definitive_request)
          end
        end
      end
    end
  end
end