module CouchObject
  # Represents a CouchDb document
  class Document    
    include Enumerable
    
    # initializes a new document object with +attributes+ as 
    # the document values
    def initialize(attributes={})
      @attributes = attributes.dup
      @id = @attributes.delete("_id")
      @revision = @attributes.delete("_rev")
    end
    attr_accessor :attributes, :id, :revision
    
    # Sets the id to +new_id+
    # (Only for internal use really, but public nevertheless)
    def id=(new_id)
      if new? 
        attributes["_id"] = @id = new_id
      else
        nil
      end
    end
    
    # is this a new document? 
    def new?
      @id.nil? && @revision.nil?
    end
    
    # yields each document attribute
    def each(&blk)
      @attributes.each(&blk)
    end
    
    # Saves this document to the +database+
    def save(database)
      new? ? create(database) : update(database)
    end
    
    # Look up an attribute by +key+
    def [](key)
      attributes[key]
    end
    
    # Set an attributes by +key+ to +value+
    def []=(key, value)
      attributes[key] = value
    end
    
    # is the attribute +key+ in this document?
    def has_key?(key)
      attributes.has_key?(key)
    end

    # is the attribute +key+ in this document?    
    def respond_to?(meth)
      method_name = meth.to_s
      
      if has_key?(method_name)
        return true
      elsif %w[ ? = ].include?(method_name[-1..-1]) && has_key?(method_name[0..-2])
        return true
      end
      
      super
    end
    
    # Converts the Document to a JSON representation of its attributes
    def to_json(extra={})
      if id.nil?
        opts = {}.merge(extra)
      else
        opts = {"_id" => id}.merge(extra)
      end
      attributes.merge(opts).to_json
    end
    
    protected
      def create(database)
        response = database.post("", self.to_json)
        # TODO error handling
        @id = response.to_document.id
        @revision = response.to_document.revision
        response
      end
      
      def update(database)
        response = database.put(id, self.to_json("_rev" => revision))
        # TODO error handling
      end
      
    private
      def method_missing(method_symbol, *arguments)
        method_name = method_symbol.to_s
      
        case method_name[-1..-1]
          when "="
            self[method_name[0..-2]] = arguments.first
          when "?"
            self[method_name[0..-2]] == true
          else
            has_key?(method_name) ? self[method_name] : super
        end
      end
  end
end