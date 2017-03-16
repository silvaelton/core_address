module CoreAddress
  class NotaryOffice < ApplicationRecord

    self.table_name = 'extranet.address_notary_offices'

    belongs_to :unit
  end
end
