module Address
  class UnitUpload

    include ActiveModel::Model


    attr_accessor :file_path, :enterprise_id, :enterprise_typology_id


    validates :enterprise_id, :enterprise_typology_id, presence: true

    validates :file_path,  presence: true
    validates :file_path, file_size: { less_than_or_equal_to: 10.megabytes.to_i }
    validates :file_path, file_content_type: { allow: ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'], message: 'Somente arquivos .xlsx' }


    def import_files!

      spreadsheet = Roo::Excelx.new(self.file_path.path, nil, :ignore)
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        print_hash = Hash[[header, spreadsheet.row(i)].transpose]

        if print_hash.present? && !print_hash.any? {|k,v| v.nil? }

          address_unit = Address::Unit.new

          address_unit.acron_block                = print_hash["SIGLA_QUADRA"].present? ? print_hash["SIGLA_QUADRA"] : nil
          address_unit.block                      = print_hash["QUADRA"]
          address_unit.acron_group                = print_hash["SIGLA_CONJUNTO"].present? ? print_hash["SIGLA_CONJUNTO"] : nil
          address_unit.group                      = print_hash["CONJUNTO"].present? ? print_hash["CONJUNTO"] : nil
          address_unit.acron_unit                 = print_hash["SIGLA_UNIDADE"].present? ? print_hash["SIGLA_UNIDADE"] : nil
          address_unit.unit                       = print_hash["UNIDADE"]
          address_unit.area                       = print_hash["AREA"]
          address_unit.complete_address           = print_hash["END_COMPLETO"]
          address_unit.situation_unit_id          = print_hash["SITUACAO_UNIDADE"]
          address_unit.donate                     = print_hash["DOADO"]
          address_unit.city_id                    = print_hash["CIDADE"]
          address_unit.urb                        = print_hash["URB"].present? ? print_hash["URB"] : nil
          address_unit.program                    = print_hash["PROGRAMA"].present? ? print_hash["PROGRAMA"] : nil
          address_unit.burgh                      = print_hash["BAIRRO"].present? ? print_hash["BAIRRO"] : nil
          address_unit.project_enterprise_id      = self.enterprise_id
          address_unit.enterprise_typology_id     = self.enterprise_typology_id
          

          begin
            address_unit.save!
          rescue Exception => e
            errors.add(:file_path, "Ocorreu um erro ao processar")
          end
        end
      end
    end


  end
end
