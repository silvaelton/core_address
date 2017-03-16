module Address
  class SituationUnit < ActiveRecord::Base

    audited

  has_many :unit

  end
end
