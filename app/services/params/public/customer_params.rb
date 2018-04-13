module Params
  module Public
    class CustomerParams < ApplicationParams
      def permit(params)
        params.require(:customer).permit(*self.class.permitted_keys)
      end

      def self.permitted_keys
        %i[first_name last_name street_address zipcode city email]
      end
    end
  end
end
