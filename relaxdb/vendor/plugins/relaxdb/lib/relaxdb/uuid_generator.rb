module RelaxDB

  class UuidGenerator
  
    def self.uuid
      unless @length
        @uuid ||= UUID.new 
        @uuid.generate
      else
        rand.to_s[2, @length]
      end
    end
  
    # Convenience that helps relationship debuggging and model exploration
    def self.id_length=(length)
      @length = length
    end
  
  end

end
