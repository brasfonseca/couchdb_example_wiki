module CouchObject
  # A CouchDb database object
  class Database
    # Create a new database at +uri+ with the name if +dbname+
    def self.create!(uri, dbname)
      server = Server.new(uri)
      response = Response.new(server.put("/#{dbname}", "")).parse
      response.parsed_body
    end
    
    # Delete the database at +uri+ with the name if +dbname+
    def self.delete!(uri, dbname)
      server = Server.new(uri)
      response = Response.new(server.delete("/#{dbname}")).parse
      response.parsed_body
    end
    
    # All databases at +uri+
    def self.all_databases(uri)
      # FIXME: Move to Server ?
      server = Server.new(uri)
      resp = server.get("/_all_dbs")
      response = Response.new(resp).parse
      response.parsed_body
    end
    
    # Open a connection to the database at +uri+, where +uri+ is a full uri
    # like: http://localhost:8888/foo
    def self.open(uri)
      uri = URI.parse(uri)
      server_uri = "#{uri.scheme}://#{uri.host}:#{uri.port}"
      new(server_uri, uri.path.tr("/", ""))
    end
    
    def initialize(uri, dbname)
      @uri = uri
      @dbname = dbname
      @server = Server.new(@uri)
    end
    attr_accessor :server
    
    # The full url of this database, eg http://localhost:8888/foo
    def url
      Utils.join_url(@uri, @dbname).to_s
    end
    
    # Name of this database
    def name
      @dbname.dup
    end
    
    # Send a GET request to the +path+ which is relative to the database path
    # so calling with with "bar" as the path in the "foo_db" database will call
    # http://host:port/foo_db/bar.
    # Returns a Response object
    def get(path)
      Response.new(@server.get("/#{Utils.join_url(@dbname, path)}")).parse
    end
    
    # Send a POST request to the +path+ which is relative to the database path
    # so calling with with "bar" as the path in the "foo_db" database will call
    # http://host:port/foo_db/bar. The post body is the +payload+
    # Returns a Response object
    def post(path, payload)
      Response.new(@server.post("/#{Utils.join_url(@dbname, path)}", payload)).parse
    end
    
    # Send a PUT request to the +path+ which is relative to the database path
    # so calling with with "bar" as the path in the "foo_db" database will call
    # http://host:port/foo_db/bar. The put body is the +payload+
    # Returns a Response object
    def put(path, payload="")
      Response.new(@server.put("/#{Utils.join_url(@dbname, path)}", payload)).parse
    end
    
    # Send a DELETE request to the +path+ which is relative to the database path
    # so calling with with "bar" as the path in the "foo_db" database will call
    # http://host:port/foo_db/bar.
    # Returns a Response object
    def delete(path)
      Response.new(@server.delete("/#{Utils.join_url(@dbname, path)}")).parse
    end
    
    # Get a document by id
    def [](id)
      get(id.to_s)
    end
    
    # Get a document by +id+, optionally a specific +revision+ too
    def document(id, revision=nil)
      if revision
        get("#{id}?rev=#{revision}")
      else
        get(id.to_s)
      end
    end
    
    # Returns an Array of all the documents in this db
    def all_documents
      resp = Response.new(get("_all_docs")).parse
      resp.to_document.rows
    end
    
    def store(document)
      document.save(self)
    end
    
    # Queries the database with the block (using a temp. view)
    # Requires a block argument that's the doc thats evaluted in 
    # CouchDb
    #
    # >> pp db.filter do |doc| 
    #     if doc["foo"] == "baz" 
    #       return doc["foo"] 
    #     end
    #   end
    # [{"_rev"=>928806717,
    #   "_id"=>"28D568C5992CBD2B4711F57225A19517",
    #   "value"=>"baz"}]
    def filter(&block)
      resp = Response.new(post("_temp_view", ProcCondition.new(&block).to_ruby)).parse
      resp.to_document.rows
    end
    
    def views(view_name)
      view = View.new(self, view_name)
      view.query
    end
    
  end
end