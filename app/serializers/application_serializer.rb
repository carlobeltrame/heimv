class ApplicationSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  # has_one :owner

  # attributes :id, :name, :zip, :place, :area, :address, :lv03_coordinates,
  #            :altitude, :max_headcount, :description, :specialities, :remarks, :costs, :ref,
  #            :locale, :state, :canton, :premium, :reservations_allowed, :season_starts_at, :season_ends_at
end