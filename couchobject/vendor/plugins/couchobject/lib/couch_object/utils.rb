module CouchObject
  module Utils
    def self.join_url(*paths)
      if paths.any?{ |path| /:\/\// =~ path }
        URI.join(*paths).to_s
      else
        paths.map do |path|
          path.gsub(/[\/]+$/, "").gsub(/^[\/]+/, "")
        end.join("/")
      end
    end
  end
end