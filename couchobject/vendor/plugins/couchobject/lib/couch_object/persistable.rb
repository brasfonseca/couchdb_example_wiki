module CouchObject
  module Persistable    
    def self.included(klazz)
      klazz.extend(ClassMethods)
    end
    
    module ClassMethods
      # Get a document from +db_uri+ with +id+ as the document id
      def get_by_id(db_uri, id)
        raise NoFromCouchMethodError unless respond_to?(:from_couch)
        db = CouchObject::Database.open(db_uri)
        response = db.get(id)
        self.send(:from_couch, response["attributes"])
      end
    end
    
    # Save the object to +db_uri+
    def save(db_uri)
      db = CouchObject::Database.open(db_uri)
      response = db.post("", self.to_json)
      unless response.empty?
        @id = response["_id"]
      end
      response
    end
    
    # Is this a new unsaved object?
    def new?
      id.nil?
    end

    # the Couch document id of this object
    def id
      @id
    end

    # serializes this object, based on its #to_couch method, into JSON
    def to_json
      raise NoToCouchMethodError unless respond_to?(:to_couch)
      {"class" => self.class, "attributes" => self.to_couch}.to_json
    end
    
    class NoToCouchMethodError < StandardError
      def message
        "You need to define a #to_couch method that returns a hash of the " + 
        "attributes you want to persist"
      end
      alias_method :to_s, :message
    end
    
    class NoFromCouchMethodError < StandardError
      def message
        "You need to define a from_couch(attrs) class method that maps attrs " + 
        "to your class instance"
      end
      alias_method :to_s, :message
    end
  end
end