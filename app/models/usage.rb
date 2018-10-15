class Usage < ApplicationRecord
  after_initialize do
    self.class.include(tarif.class::UsageDecorator) if tarif && defined?(tarif.class::UsageDecorator)
  end

  belongs_to :tarif, inverse_of: :usages
  belongs_to :booking, inverse_of: :usages
  has_many :invoice_parts, dependent: :nullify

  attribute :apply, default: true

  scope :ordered, -> { order(tarif: { row_order: :ASC, created_at: :ASC }) }
  scope :of_tarif, ->(tarif) { where(tarif_id: tarif.self_and_booking_copy_ids) }

  before_create :create_tarif_booking_copy

  validates :tarif_id, uniqueness: { scope: :booking_id }, allow_nil: true

  def price
    ((used_units || 0) * tarif.price_per_unit || 1).floor(2)
  end

  def of_tarif?(other_tarif)
    other_tarif.self_and_booking_copy_ids.include?(tarif_id)
  end

  def create_tarif_booking_copy
    return if tarif.booking_copy? || tarif.transient?

    self.tarif = TarifBuilder.new.booking_copy_for(tarif, booking).tap(&:save)
  end
end