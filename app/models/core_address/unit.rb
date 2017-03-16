module CoreAddress
  class Unit < ApplicationRecord

    self.table_name = 'extranet.address_units'

    belongs_to :situation_unit
    belongs_to :ownership_type,    required: false
    belongs_to :city
    belongs_to :type_use_unit,     required: false,
    belongs_to :project_enterprise,required: false,  class_name: ::CoreAddress::Project::Enterprise,  foreign_key: 'project_enterprise_id'

    has_one :notary_office

    has_many :registry_units
    has_many :cadastre_address,                      class_name: ::CoreAddress::Candidate::CadastreAddress
    has_many :cadastres, through: :cadastre_address, class_name: ::CoreAddress::Candidate::Cadastre
    has_many :ammvs,                                 class_name: ::CoreAddress::Candidate::Ammv
    has_many :activity




   private

   def ammvs_candidate
    CoreAddress::Ammv.find_by_unit_id(self.id) rescue false
   end


   def self.update_situation(unit,status)
       @unit = CoreAddress::Unit.find(unit)
       @unit.update(situation_unit_id: status)
   end


  end
end
