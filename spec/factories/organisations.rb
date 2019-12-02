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

FactoryBot.define do
  factory :organisation do
    name { 'Heimverein St. Georg' }
    address { 'MyText' }
    booking_strategy_type { BookingStrategies::Default.to_s }
    invoice_ref_strategy_type { RefStrategies::ESR.to_s }
    payment_information { 'MyString' }
    account_nr { 'MyString' }
  end
end
