module Address
  class Rescission
    include ActiveModel::Model 

    attr_accessor :observation

    validates :observation, presence: true

  end
end