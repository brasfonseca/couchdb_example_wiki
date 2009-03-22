require "net/http"

module CouchObject
  class Server
    # Create a new Server object, +uri+ is the full URI of the server,
    # eg. "http://localhost:8888"
    def initialize(uri)
      @uri = URI.parse(uri)
      @host = @uri.host
      @port = @uri.port
      @connection = Net::HTTP.new(@host, @port)
      @connection.set_debug_output($stderr) if $debug
    end
    attr_accessor :host, :port, :connection
    
    # Send a GET request to +path+
    def get(path)
      request(Net::HTTP::Get.new(path))
    end
    
    # Send a POST request to +path+ with the body payload of +data+
    # +content_type+ is the Content-Type header to send along (defaults to
    # application/json)
    def post(path, data, content_type="application/json")
      post = Net::HTTP::Post.new(path)
      post["content-type"] = content_type
      post.body = data
      request(post)      
    end
    
    # Send a PUT request to +path+ with the body payload of +data+
    # +content_type+ is the Content-Type header to send along (defaults to
    # application/json)
    def put(path, data, content_type="application/json")
      put = Net::HTTP::Put.new(path)
      put["content-type"] = content_type
      put.body = data
      request(put)
    end
    
    # Send a DELETE request to +path+
    def delete(path)
      req = Net::HTTP::Delete.new(path)
      request(req)
    end
    
    # send off a +req+ object to the host. req is a Net::Http:: request class
    # (eg Net::Http::Get/Net::Http::Post etc)
    def request(req)
      connection.request(req)
    end    
  end
end