module Manage
  class HomeSerializer < Public::HomeSerializer
    # has_many :bookings

    attributes :janitor, :place, :min_occupation
  end
end
