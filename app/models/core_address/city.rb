module CoreAddress
  class City < ApplicationRecord
<<<<<<< HEAD
    self.table_name = 'extranet.address_cities'
  end
end
=======

    self.table_name = 'extranet.address_cities'

    belongs_to :state

    scope :federal_district, -> { joins(:state)
                                  .where('address_states.acronym = ?', 'DF')
                                  .order(:name) }
  end
end
>>>>>>> b6113b06e1026755bbad3c996c9f5e5d21a2325c
