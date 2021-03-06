# frozen_string_literal: true

module Manage
  class DataDigestParams < ApplicationParams
    def self.permitted_keys
      %i[type label] + [{ tarif_ids: [], filter_params: {} }]
    end
  end
end
