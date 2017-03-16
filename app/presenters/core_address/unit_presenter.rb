module CoreAddress
  class UnitPresenter < ApplicationPresenter

    def unit_block?
      unit_book? || self.situation_unit_id == 3 &&  current_cadastre_address.present? && current_cadastre_address.distribuído?
    end

    def unit_occupied?
      [5,9,10,12].include? self.situation_unit_id
    end

    def unit_book?

      self.situation_unit_id == 6 && current_cadastre_address.present? && current_cadastre_address.reserva?
    end

    def unit_void?
      self.situation_unit_id == 1 && (current_cadastre_address.nil? || current_cadastre_address.distrato?)
    end

    def contract_delivered
      @contract_delivered ? "Sim" : "Não"
    end

    def current_cadastre_address
      self.cadastre_address.order('created_at ASC').last rescue nil
    end

    def current_registry_id
      registry_units.order('id ASC').last.situation rescue I18n.t(:no_information)
    end

    def current_candidate
      address = self.cadastre_address.order('created_at asc').last rescue nil

      return false if address.nil?
      return false unless %w(reserva distribuído sobrestado).include?(address.situation_id)

      cadastre = address.cadastre rescue nil

    end

    def dweller
      object_ammvs      = self.ammvs.last
      object_cadastre   = self.cadastres.last

      if object_ammvs.present?
        object_ammvs
      elsif object_cadastre.present?
        object_cadastre
      else
        nil
      end
    end

    def dweller_name
      return "Sem informação" if dweller.nil?
      dweller.name.upcase
    end

    def dweller_cpf
      return "Sem informação" if dweller.nil?
      dweller.cpf
    end


    def date_tcu
      last_cadastre_address = self.cadastre_address.last
      if last_cadastre_address.present?
        last_cadastre_address.created_at.strftime("%d/%m/%Y")
      else
        nil
      end
    end

    def ammvs_cdru
      cdru_ammvs = self.ammvs.last
      cadastre   = self.cadastres.last

      return "Imóvel vago" if cdru_ammvs.nil? && cadastre.nil?

      tcu = Date.parse(date_tcu) rescue nil

      if cdru_ammvs.present? && cdru_ammvs.cdru == "SIM"
        "Incluso na CDRU"
      else
        return "Não possui cadastro na CODHAB" if cadastre.nil?
        not_present_cdru(tcu)
      end
    end

    def ammvs_cdru_observation
      cdru_ammvs = self.ammvs.last
      cdru_ammvs.present? ? cdru_ammvs.cdru_observation.downcase : "Sem informação"
    end

    def ammvs_finance_agent
      cdru_ammvs = self.ammvs.last
      return "Sem informação" if cdru_ammvs.nil?
      cdru_ammvs.finance_agent
    end

    def ammvs_constructor
      cdru_ammvs = self.ammvs.last
      return "Sem informação" if cdru_ammvs.nil?
      cdru_ammvs.constructor
    end

    def ammvs_entity_name
      cdru_ammvs = self.ammvs.last
      cadastre   = self.cadastres.last

      if cdru_ammvs.present?
        cadastre_ammvs    = Candidate::Cadastre.find_by_cpf(cdru_ammvs.cpf) rescue nil
        candidate_entity  = Entity::OldCandidate.find_by_cadastre_id(cadastre_ammvs.id) rescue nil
      elsif cadastre.present?
        candidate_entity = Entity::OldCandidate.find_by_cadastre_id(cadastre.id) rescue nil
      end

      candidate_entity.present? ? candidate_entity.old.fantasy_name : "Sem informação"
    end

    def not_present_cdru(tcu)
      if tcu.present?
        if tcu >= Date.parse('05/05/2016')
          "4º Termo Aditivo"
        elsif tcu < Date.parse('05/05/2016')
          "Migrado sem autorização"
        end
      else
        "Sem informação"
      end
    end

    def set_color
      case self.ammvs_cdru
      when 'Incluso na CDRU'
        'warning'
      when '4º Termo Aditivo'
        'danger'
      when 'Migrado sem autorização'
        'danger'
      when 'Não possui cadastro na CODHAB'
        'danger'
      when 'Imóvel vago'
        'primary'
      when 'black'
        'black'
      end
    end

    def candidate_in_unit
    ammvs = ammvs_candidate
    if ammvs.present?
      ammvs_candidate
    else
      unit = Candidate::CadastreAddress.where(unit_id: self.id).order('created_at').last rescue nil
      return false if unit.nil?
      Candidate::Cadastre.find(unit.cadastre_id)
    end
    end

    def self.json(address)
      data = Array.new

      address.order(:complete_address).each do |addr|
        data << {
          coordinate: addr.coordinate.to_s.split(','),
          complete_address: addr.complete_address,
          unit: addr.unit,
          name: addr.dweller_name,
          cpf:  addr.dweller_cpf,
          cpf_formated: (addr.dweller_cpf != "Sem informação") ? addr.dweller_cpf.format_cpf : "",
          tcu:  addr.date_tcu.present? ? addr.date_tcu : "Sem informação",
          color: addr.set_color,
          cdru: addr.ammvs_cdru,
          cdru_observation: addr.ammvs_cdru_observation,
          cdru_finance_agent: addr.ammvs_finance_agent,
          cdru_constructor: addr.ammvs_constructor,
          entity: addr.ammvs_entity_name
        }
      end

      data
    end
  end
end
