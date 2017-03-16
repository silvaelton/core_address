module Address
  class Transfer
    include ActiveModel::Model

    attr_accessor :cpf, :observation, :unit_id

    validates :cpf, cpf: true, presence: true
    validates :observation, presence: true

    validate :cpf_allow?

    def transfer!

      #clone cadastre address
      #add new cadastre address 'transferido'
      address_unit         = unit
      candidate            = address_unit.current_candidate
      new_candidate        = Candidate::Cadastre.find_by_cpf(self.cpf)
      cadastre_address     = address_unit.current_cadastre_address
      new_cadastre_address = address_unit.cadastre_address.new

      cadastre_address.attributes.each do |key, value|
        unless %w(id created_at updated_at).include? key
          new_cadastre_address[key] = value if new_cadastre_address.attributes.has_key?(key)
        end
      end

      new_cadastre_address.situation_id = 'transferido'
      new_cadastre_address.save

      # update old candidate
      update_candidate(candidate, 77, 8)

      # add cadastre address to new candidate
      create_candidate_address('distribuído', address_unit, new_candidate)

      # update situation and procedural of new candidate
      #update_candidate(new_candidate, 4, 7)

      # update para contemplação do candidato
      @situation = new_candidate.cadastre_situations.new({
        situation_status_id: 7
      })

      @situation.save

      # find last assessment unit
      @old_procedural = Candidate::CadastreProcedural.where(cadastre_id: candidate).order("created_at desc").first

      # update procedural of candidate
      @procedural = new_candidate.cadastre_procedurals.new({
        procedural_status_id: 4,
        convocation_id: @old_procedural.convocation_id,
        assessment_id: @old_procedural.assessment_id,
        observation: "Transferencia de imóvel via sistema."
      })

      @procedural.save

    end

    private

    def create_candidate_address(situation, address, candidate)

      address.cadastre_address.new({
        cadastre_id:    candidate.id,
        situation_id:   situation,
        unit_id:        address.id,
        dominial_chain: address.current_cadastre_address.dominial_chain.to_i + 1,
        observation:    self.observation,
        type_occurrence: 0,
        type_receipt:    1
      }).save

    end

    def update_candidate(candidate, procedural, situation)
      service = Candidate::SituationService.new(candidate)
      service.add_situation(situation)
      service.add_procedural(procedural)
    end


    def unit
      Address::Unit.find(self.unit_id) rescue nil
    end

    def cpf_allow?
      candidate = Candidate::Cadastre.find_by_cpf(self.cpf) rescue nil

      if unit.nil?
        errors.add(:cpf, "Endereço solicĩtado não existe")
      else
        if unit.current_candidate.present?
          if unit.current_candidate.cpf == self.cpf
            errors.add(:cpf, "CPF é o último na cadeia dominial, favor informar outro")
          end
        end
      end

      if candidate.nil?
        errors.add(:cpf, "CPF não existe na base da dados")
      else
        unless [3,6].include? candidate.program_id
          errors.add(:cpf, "CPF não está vínculado ao programa de Regularização")
        end

        unless [4, 3].include? candidate.current_situation_id
          errors.add(:cpf, "CPF não se encontra HABILITADO ou CONVOCADO")
        end

        unless [14,64,65,66].include? candidate.current_procedural.procedural_status_id
          errors.add(:cpf, "CPF não se encontra com situação processual válida para transferência")
        end
      end
    end


  end
end
