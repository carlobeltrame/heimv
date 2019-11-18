# == Schema Information
#
# Table name: data_digests
#
#  id            :bigint           not null, primary key
#  type          :string
#  label         :string
#  filter_params :jsonb
#  data_digest_params :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

module DataDigests
  class Tenant < Booking
    def tarif_ids=(tarif_ids)
      data_digest_params['tarif_ids'] = tarif_ids.reject(&:blank?)
    end

    def tarif_ids
      data_digest_params.fetch('tarif_ids', [])
    end

    def tarifs
      ::Tarif.where(id: tarif_ids)
    end

    def column_widths
      [70, 80, 100, 100, 60, 140, 140, 50]
    end

    protected

    def generate_tabular_header
      super + [
        ::Tenant.model_name.human, '', ::Occupancy.human_attribute_name(:nights)
      ]
    end

    def generate_tabular_row(booking)
      super + booking.instance_eval do
        [
          tenant.address_lines.join("\n"), [tenant.email, tenant.phone].join("\n"), occupancy.nights
        ]
      end
    end
  end
end