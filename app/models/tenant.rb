# == Schema Information
#
# Table name: tenants
#
#  id                   :bigint           not null, primary key
#  first_name           :string
#  last_name            :string
#  street_address       :string
#  zipcode              :string
#  city                 :string
#  country              :string
#  reservations_allowed :boolean
#  email_verified       :boolean          default(FALSE)
#  phone                :text
#  remarks              :text
#  email                :string           not null
#  search_cache         :text             not null
#  birth_date           :date
#  import_data          :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Tenant < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error
  belongs_to :organisation

  validates :email, presence: true, format: { with: Devise.email_regexp }
  validates :first_name, :last_name, :street_address, :zipcode, :city, presence: true, on: :public_update
  validates :birth_date, presence: true, on: :public_update
  validates :phone, presence: true, length: { minimum: 10 }, on: :public_update

  before_save do
    self.search_cache = (address_lines + [email, phone]).flatten.join('\n')
  end

  def name
    "#{first_name} #{last_name}"
  end

  def salutation_name
    "Hallo #{first_name}"
  end

  def address_lines
    [name, street_address, "#{zipcode} #{city} #{country}"].reject(&:blank?)
  end

  def contact_lines
    address_lines + [phone, email].reject(&:blank?)
  end

  def email_validated!
    update(email_validated: true)
  end

  def to_s
    "##{id} #{name}"
  end

  def to_liquid
    Public::TenantSerializer.new(self).serializable_hash.deep_stringify_keys
  end
end
