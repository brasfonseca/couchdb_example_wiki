module RelaxDB
  
  class HTTP_404 < StandardError; end
  class HTTP_409 < StandardError; end
  class HTTP_412 < StandardError; end

  class Server
        
    def initialize(host, port)
      @host = host
      @port = port
    end

    def delete(uri)
      request(Net::HTTP::Delete.new(uri))
    end

    def get(uri)
      request(Net::HTTP::Get.new(uri))
    end

    def put(uri, json)
      req = Net::HTTP::Put.new(uri)
      req["content-type"] = "application/json"
      req.body = json
      request(req)
    end

    def post(uri, json)
      req = Net::HTTP::Post.new(uri)
      req["content-type"] = "application/json"
      req.body = json
      request(req)
    end

    def request(req)
      res = Net::HTTP.start(@host, @port) {|http|
        http.request(req)
      }
      if (not res.kind_of?(Net::HTTPSuccess))
        handle_error(req, res)
      end
      res
    end
    
    def to_s
      "http://#{@host}:#{@port}/"
    end
    
    private

    def handle_error(req, res)
      msg = "#{res.code}:#{res.message}\nMETHOD:#{req.method}\nURI:#{req.path}\n#{res.body}"
      begin
        klass = RelaxDB.const_get("HTTP_#{res.code}")
        e = klass.new(msg)
      rescue
        e = RuntimeError.new(msg)
      end

      raise e
    end
  end
      
  class CouchDB

    attr_reader :logger
        
    # Used for test instrumentation only i.e. to assert that 
    # an expected number of requests have been issued
    attr_accessor :get_count, :put_count, :post_count
        
    def initialize(config)
      @get_count, @post_count, @put_count = 0, 0, 0
      @server = RelaxDB::Server.new(config[:host], config[:port])
      @logger = config[:logger] ? config[:logger] : Logger.new(Tempfile.new('couchdb.log'))
    end
    
    def use_db(name)
      create_db_if_non_existant(name)
      @db = name
    end
    
    def db_exists?(name)
      @server.get("/#{name}") rescue false
    end
    
    def delete_db(name)
      @logger.info("Deleting database #{name}")
      @server.delete("/#{name}")
    end
    
    def list_dbs
      JSON.parse(@server.get("/_all_dbs").body)
    end
    
    def replicate_db(source, target)
      @logger.info("Replicating from #{source} to #{target}")
      create_db_if_non_existant target      
      data = { "source" => source, "target" => target}
      @server.post("/_replicate", data.to_json)
    end

    def delete(path=nil)
      @logger.info("DELETE /#{@db}/#{unesc(path)}")
      @server.delete("/#{@db}/#{path}")
    end
    
    def get(path=nil)
      @get_count += 1
      @logger.info("GET /#{@db}/#{unesc(path)}")
      @server.get("/#{@db}/#{path}")
    end
        
    def post(path=nil, json=nil)
      @post_count += 1
      @logger.info("POST /#{@db}/#{unesc(path)} #{json}")
      @server.post("/#{@db}/#{path}", json)
    end
    
    def put(path=nil, json=nil)
      @put_count += 1
      @logger.info("PUT /#{@db}/#{unesc(path)} #{json}")
      @server.put("/#{@db}/#{path}", json)
    end
    
    def unesc(path)
      # path
      path ? ::CGI::unescape(path) : ""
    end
    
    def uri
      "#@server" / @db
    end
    
    def name
      @db
    end
    
    def name=(name)
      @db = name
    end
        
    private
    
    def create_db_if_non_existant(name)
      begin
        @server.get("/#{name}")
      rescue
        @server.put("/#{name}", "")
      end
    end
    
  end
        
end
