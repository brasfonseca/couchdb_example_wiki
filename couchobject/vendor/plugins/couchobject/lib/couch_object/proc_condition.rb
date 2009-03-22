module CouchObject
  class ProcCondition
    def initialize(&block)
      unless block.arity == 1
        raise ArgumentError, "wrong number of arguments (#{block.arity+1} for 1)"
      end
      @block = block
    end
    
    def to_ruby
      @block.to_ruby.squeeze(" ")
    end
  end
end