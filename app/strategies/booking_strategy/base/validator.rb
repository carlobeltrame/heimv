module BookingStrategy
  module Base
    class Validator < ActiveModel::Validator
      def validate(record); end
    end
  end
end