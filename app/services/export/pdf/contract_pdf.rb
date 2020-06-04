require 'prawn'

module Export
  module Pdf
    class ContractPdf < Base
      def initialize(contract)
        @contract = contract
        @booking = contract.booking
        @organisation = @booking.organisation
      end

      to_render do
        render Renderables::Logo.new(@organisation.logo)
        render Renderables::AddressedHeader.new(@booking)
        render Renderables::Markdown.new(@contract.text)
      end

      to_render do
        next if tarifs.blank?

        move_down 10
        table(tarif_table_data, column_widths: [200, 200, 94]) do
          rows(0).style(font_style: :bold)
          cells.style(borders: [], padding: [0, 0, 4, 0])
          column(2).style(align: :right)
        end
      end

      to_render do
        render Renderables::Signatures.new(@contract)
      end

      def tarifs
        @tarifs ||= @booking.used_tarifs
      end

      def tarif_table_data
        [[Tarif.model_name.human, Tarif.human_attribute_name(:unit), Tarif.human_attribute_name(:price_per_unit)]] +
          tarifs.map do |tarif|
            [tarif.label, tarif.unit, format('CHF %<price>.2f', price: tarif.price_per_unit)]
          end
      end
    end
  end
end