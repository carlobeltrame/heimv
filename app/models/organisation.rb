# == Schema Information
#
# Table name: organisations
#
#  id                        :bigint           not null, primary key
#  account_nr                :string
#  address                   :text
#  booking_strategy_type     :string
#  currency                  :string           default("CHF")
#  invoice_ref_strategy_type :string
#  message_footer            :text
#  name                      :string
#  payment_information       :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class Organisation < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :homes, dependent: :restrict_with_error, inverse_of: :organisation
  has_one_attached :logo
  has_one_attached :terms_pdf
  has_one_attached :privacy_statement_pdf

  validates :booking_strategy_type, presence: true
  validates :invoice_ref_strategy_type, presence: true
  validates :name, :address, :account_nr, presence: true

  def booking_strategy
    Kernel.const_get(booking_strategy_type).new
  end

  def invoice_ref_strategy
    Kernel.const_get(invoice_ref_strategy_type).new
  end

  def long_deadline
    8.days
  end

  def short_deadline
    3.days
  end

  def to_s
    name
  end
end
