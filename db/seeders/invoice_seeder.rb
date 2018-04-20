require_relative './base_seeder'

module Seeders
  class InvoiceSeeder < BaseSeeder
    def seed_development
      {
        invoices: seeds.fetch(:bookings, []).map do |booking|
          create(:invoice, booking: booking)
        end
      }
    end
  end
end
