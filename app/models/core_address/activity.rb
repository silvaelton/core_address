module CoreAddress
  class Activity < ApplicationRecord

    self.table_name = 'extranet.address_activities'

    belongs_to :unit
    belongs_to :staff, class_name: "CoreAddress::Person::Staff"
    belongs_to :activity_status

  end
end
