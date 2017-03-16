module CoreAddress
  class City < ApplicationRecord

    self.table_name = 'extranet.address_cities'

    belongs_to :state

    scope :federal_district, -> { joins(:state)
                                  .where('address_states.acronym = ?', 'DF')
                                  .order(:name) }
  end
end
