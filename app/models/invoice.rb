# == Schema Information
#
# Table name: invoices
#
#  id                 :bigint           not null, primary key
#  amount             :decimal(, )      default(0.0)
#  deleted_at         :datetime
#  issued_at          :datetime
#  paid               :boolean          default(FALSE)
#  payable_until      :datetime
#  payment_info_type  :string
#  print_payment_slip :boolean          default(FALSE)
#  ref                :string
#  sent_at            :datetime
#  text               :text
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  booking_id         :uuid
#
# Indexes
#
#  index_invoices_on_booking_id  (booking_id)
#  index_invoices_on_ref         (ref)
#  index_invoices_on_type        (type)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#

class Invoice < ApplicationRecord
  belongs_to :booking, inverse_of: :invoices, touch: true
  has_many :invoice_parts, -> { order(position: :asc) }, inverse_of: :invoice, dependent: :destroy
  has_many :payments, dependent: :nullify
  has_one_attached :pdf
  has_one :organisation, through: :booking

  scope :ordered, -> { order(payable_until: :ASC, created_at: :ASC) }
  scope :relevant, -> { where(deleted_at: nil) }
  scope :unpaid,  -> { relevant.where(paid: false) }
  scope :paid,    -> { relevant.where(paid: true) }
  scope :sent,    -> { relevant.where.not(sent_at: nil) }
  scope :unsent,  -> { relevant.where(sent_at: nil) }
  scope :overdue, ->(at = Time.zone.today) { relevant.where(arel_table[:payable_until].lteq(at)) }
  scope :of, ->(booking) { where(booking: booking) }

  accepts_nested_attributes_for :invoice_parts, reject_if: :all_blank, allow_destroy: true
  before_save :set_paid
  before_save :generate_pdf
  after_touch :recalculate_amount

  def generate_pdf
    self.pdf = {
      io: StringIO.new(Export::Pdf::Invoice.new(self).build.render),
      filename: filename,
      content_type: 'application/pdf'
    }
  end

  def ref
    @ref ||= invoice_ref_strategy.generate(self) unless new_record?
  end

  def recalculate_amount
    update(amount: invoice_parts.reduce(0) { |result, invoice_part| invoice_part.inject_self(result) })
  end

  def filename
    "#{self.class.model_name.human} #{booking.ref}_#{id}.pdf"
  end

  def address_lines
    @address_lines ||= booking.invoice_address&.lines.presence || booking.tenant&.address_lines || []
  end

  def amount_open
    amount - amount_paid
  end

  def amount_paid
    payments.sum(&:amount)
  end

  def set_paid
    self.paid = amount_open.zero?
  end

  def sent!
    update(sent_at: Time.zone.now)
  end

  def deleted?
    deleted_at.present?
  end

  def to_s
    invoice_ref_strategy.format_ref(ref)
  end

  def invoice_ref_strategy
    @invoice_ref_strategy ||= organisation.invoice_ref_strategy
  end

  def payment_info
    @payment_info ||= PaymentInfos.const_get(payment_info_type).new(self) if payment_info_type.present?
  end
end
