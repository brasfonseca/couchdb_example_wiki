module CouchObject
  # The response returned from the database
  class Response
    def initialize(response)
      @response = response
    end
    
    # the response HTTP code
    def code
      @response.code.to_i
    end
    
    # the body
    def body
      @response.body
    end
    
    # The parsed (to JSON) body
    def parsed_body
      @parsed_body
    end
    
    # is the request considered a success?
    def success?
      # FIXME: make better
      (200...400).include?(code.to_i)
    end
    
    # Returns a CouchObject::Document with the +parsed_body+ set as the attributes
    def to_document
      if @parsed_body
        Document.new(@parsed_body)
      else
        Document.new(parse.parsed_body)
      end
    end
    
    # Parse the response body into JSON and return +self+
    def parse
      @parsed_body = JSON.parse(body)
      self
    end
  end
end