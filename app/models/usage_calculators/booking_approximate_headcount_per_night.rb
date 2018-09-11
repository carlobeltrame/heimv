module UsageCalculators
  class BookingApproximateHeadcountPerNight < NumericDistinction
    def presumable_usage(usage)
      usage.booking.approximate_headcount
    end

    # def select_usage(usage, _distinction)
    #   usage.booking.nights + 1
    # end
  end
end
