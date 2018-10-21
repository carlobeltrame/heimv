class Deadline < ApplicationRecord
  belongs_to :booking, inverse_of: :deadlines
  belongs_to :responsible, polymorphic: :true, optional: true

  scope :ordered, -> { order(at: :DESC) }
  scope :current, -> { where(current: true).ordered.last }
  scope :future, -> { where(arel_table[:at].gteq(Time.zone.now)) }

  after_destroy :set_current, if: :current?
  after_save :set_current

  def exceeded?(other = Time.zone.now)
    other > at
  end

  def set_current
    last_deadlines = booking.deadlines.where(current: true).where.not(id: id)
    return unless !current || last_deadlines.exists?

    last_deadlines.update_all(current: false)
  end
end
