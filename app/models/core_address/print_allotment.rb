module CoreAddress
  class PrintAllotment < ApplicationRecord

    self.table_name = 'extranet.address_print_allotments'

    belongs_to :staff, class_name: "CoreAddress::Person::Staff"
    belongs_to :print_type, class_name: "CoreAddress::PrintType", foreign_key: :print_type_id
    belongs_to :unit, class_name: "CoreAddress::Unit"


    has_many :print_unit_cadastres, dependent: :destroy


  end
end
