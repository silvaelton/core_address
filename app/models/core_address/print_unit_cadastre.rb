module Address
  class PrintUnitCadastre < ApplicationRecord

    self.table_name = 'extranet.address_print_allotments'
    
    belongs_to :cadastre, class_name: "Candidate::Cadastre"
    belongs_to :unit
    belongs_to :current_unit, class_name: "Address::Unit"
    belongs_to :print_allotment


    validate :virtual_validate!, on: :create

    #validates :cpf, uniqueness: { scope: [:unit_id, :status] }, presence: true

    private

    def virtual_validate!
      self.message = ""

      @candidate = ::Candidate::Cadastre.find_by_cpf(self.cpf)
      @unit = Address::Unit.find(self.unit_id) if self.unit_id.present?
      @unit_candidate = @unit.current_cadastre_address if @unit.present?
      @declaratory = @unit.notary_office.declaratory_act_number if @unit.present? && @unit.notary_office.present?
      @declaratory_date = @unit.notary_office.date_act_declaratory if @unit.present? && @unit.notary_office.present?


      add_message_error("CPF inválido;")                                    if !ValidatesCpfCnpj::Cpf.valid?(self.cpf.format_cpf)
      add_message_error("Candidato não cadastrado na base de dados;")       unless @candidate.present?
      add_message_error("Candidato sem vinculo com endereço;")              unless @unit_candidate.present?
      add_message_error("Candidato sem reserva e/ou imóvel distribuído;")   unless @unit_candidate.present? && %w(reserva distribuído).include?(@unit_candidate.situation_id.to_s)
      add_message_error("Candidato não está no imóvel da planilha;")        if self.current_unit_id.present? && self.unit_id.present? && self.current_unit_id != self.unit_id
      add_message_error("Unidade sem ato declaratório;")                    if !@declaratory.present? && @unit.notary_office.present?
      add_message_error("Unidade sem data de ato declaratório;")            if !@declaratory_date.present? && @unit.notary_office.present?

    end

    def add_message_error(message)
      self.message  = "" if self.message.nil?
      self.message += "#{message};"
      self.status = false if self.message.present?
    end



  end
end
