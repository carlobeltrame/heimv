# == Schema Information
#
# Table name: messages
#
#  id                   :bigint           not null, primary key
#  addressed_to         :integer          default("0"), not null
#  body                 :text
#  sent_at              :datetime
#  subject              :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  booking_id           :uuid
#  markdown_template_id :bigint
#
# Indexes
#
#  index_messages_on_booking_id            (booking_id)
#  index_messages_on_markdown_template_id  (markdown_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (markdown_template_id => markdown_templates.id)
#

FactoryBot.define do
  factory :message do
    body { 'MyText' }
    sent_at { '2018-10-23 14:08:21' }
    subject { 'MyString' }

    booking { nil }
  end
end
