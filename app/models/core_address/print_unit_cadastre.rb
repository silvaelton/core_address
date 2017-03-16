module CoreAddress
  class PrintUnitCadastre < ApplicationRecord

    self.table_name = 'extranet.address_print_unit_cadastres'

    belongs_to :cadastre, class_name: ::CoreAddress::Candidate::Cadastre
    belongs_to :unit
    belongs_to :current_unit, class_name: ::CoreAddress::Unit
    belongs_to :print_allotment

  end
end
