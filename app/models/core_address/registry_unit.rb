module CoreAddress
  class RegistryUnit < ApplicationRecord

    self.table_name = 'extranet.address_registry_units'

    belongs_to :unit

    enum situation: [:não, :em_fase, :sim]

  end
end
