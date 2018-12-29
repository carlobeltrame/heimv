class MarkdownTemplate < ApplicationRecord
  KEYS = %w[
    contract_text
    invoice_text
    upcoming_message
    definitive_request_message
    overdue_request_message
    provisional_request_message
    confirmed_message
    open_request_message
    unconfirmed_request_message
    manage_new_booking_mail
  ].freeze

  validates :key, :locale, presence: true
  validates :key, uniqueness: true, inclusion: { in: KEYS }

  def to_markdown
    Markdown.new(body)
  end

  def interpolate(context)
    context = InterpolationContext.new(context) unless context.is_a?(InterpolationContext)

    Markdown.new(Liquid::Template.parse(body).render(context.to_h, [Filters]))
  end

  alias % interpolate

  def self.find_by_key(key, locale: I18n.locale)
    find_by(key: key, locale: locale)
  end

  module Filters
    def t(input, scope = nil)
      I18n.t(input, scope: scope, default: nil)
    end

    def booking_purpose(input)
      t(input, :'activerecord.enums.booking.purpose')
    end
  end
end
