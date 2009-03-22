require "enumerator"

module CouchObject
  class View
    def self.create(db, name, query)
      db.post("/#{db.name}/_view_#{name}", query)
    end
    
    def initialize(db, name)
      @db = db
      @name = name
    end
    attr_accessor :db
    
    def name
      "_view_#{@name.dup}"
    end
    
    def delete
      @db.delete("/#{db.name}/#{name}")
    end
  end
end