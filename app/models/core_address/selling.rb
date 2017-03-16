module Address
  class Selling
    include ActiveModel::Model

    attr_accessor :cpf, :observation, :cadastre

    validates :cpf, cpf: true, presence: true
    validates :observation, presence: true

    validate  :cpf_valid?

    private

    def cpf_valid?
      @cadastre = ::Candidate::Cadastre.find_by_cpf(self.cpf) rescue nil

      if @cadastre.nil?
        errors.add(:cpf, 'CPF não existe na base de dados')
        return false
      end

      if %w(1 2 4 5).include? @cadastre.program_id.to_s
        unless @cadastre.current_situation_id == 4 && @cadastre.current_procedural.procedural_status_id == 8
          errors.add(:cpf, 'Situação do CPF não é válida para esta operação')
        end
      elsif %w(3 6).include?(@cadastre.program_id.to_s)
        unless %w(3 4).include?(@cadastre.current_situation_id.to_s) && @cadastre.current_procedural.procedural_status_id == 8
          errors.add(:cpf, 'Situação do CPF não é válida para esta operação')
        end
      end

    end

  end
end
