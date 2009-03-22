= CouchObject

CouchObject is a set of classes to help you talk to CouchDb (http://couchdbwiki.com/) with Ruby.

* Author: Johan Sørensen
* Contact: johan (at) johansorensen DOT com
* Home: http://rubyforge.org/projects/couchobject/
* Source (Git): http://repo.or.cz/w/couchobject.git
 
== Creating, opening and deleting databases

CouchObject::Database is the first interaction point to your CouchDb. Creating a CouchDb database:

	>> CouchObject::Database.create!("http://localhost:8888", "mydb")
	=> {"ok"=>true}
	>> CouchObject::Database.all_databases("http://localhost:8888")
	=> ["couchobject", "couchobject_test", "foo", "mydb"]
	>> db = CouchObject::Database.open("http://localhost:8888/mydb")
	=> #<CouchObject::Database:0x642fa8 @server=#<CouchObject::Server:0x642ef4 @connection=#<Net::HTTP localhost:8888 open=false>, @port=8888, @uri=#<URI::HTTP:0x321612 URL:http://localhost:8888>, @host="localhost">, @uri="http://localhost:8888", @dbname="mydb">
	>> db.name
	=> "mydb"
	>> CouchObject::Database.delete!("http://localhost:8888", "mydb")
	=> {"ok"=>true}
	>> CouchObject::Database.all_databases("http://localhost:8888").include?("mydb")
	=> false
		
=== Interacting with the database

	>> db.get("_all_docs")
	=> #<CouchObject::Response:0x14ed364 @response=#<Net::HTTPOK 200 OK readbody=true>, @parsed_body={"rows"=>[], "view"=>"_all_docs"}>
		
Issueing CouchObject::Database#get, CouchObject::Database#post, CouchObject::Database#put and CouchObject::Database#delete requests will return a CouchObject::Response object
		
	>> db.get("_all_docs").body
	=> "{\"view\":\"_all_docs\", \"rows\":[\n\n]}"
	>> db.get("_all_docs").parsed_body
	=> {"rows"=>[], "view"=>"_all_docs"}
	>> db.post("", JSON.unparse({"foo" => "bar"}))
	=> #<CouchObject::Response:0x14d7780 @response=#<Net::HTTPCreated 201 Created readbody=true>, @parsed_body={"_rev"=>-992681820, "_id"=>"1206189E4496409DAD3818D241F5478F", "ok"=>true}>
	>> db.get("_all_docs").parsed_body
	=> {"rows"=>[{"_rev"=>-992681820, "_id"=>"1206189E4496409DAD3818D241F5478F"}], "view"=>"_all_docs"}
	>> db.get("1206189E4496409DAD3818D241F5478F").parsed_body
	=> {"_rev"=>-992681820, "_id"=>"1206189E4496409DAD3818D241F5478F", "foo"=>"bar"}
	>> db.delete("1206189E4496409DAD3818D241F5478F").parsed_body
	=> {"_rev"=>548318611, "ok"=>true}
	>> db.get("_all_docs").parsed_body
	=> {"rows"=>[], "view"=>"_all_docs"}
	
== The Couch View Requestor

couch_ruby_view_requestor is a JsServer client for CouchDb, allowing you to query documents with Ruby instead of Javascript! All you need to do is pass in a string with something that reponds to #call with one argument (the document):
  
  >> db.post("_temp_view", "proc { |doc| doc[\"foo\"] =~ /ba/ }").parsed_body["rows"]
  => [{"_rev"=>928806717, "_id"=>"28D568C5992CBD2B4711F57225A19517", "value"=>0}, {"_rev"=>-1696868121, "_id"=>"601D858DB2E298EFC4BBA92A11760D1E", "value"=>0}, {"_rev"=>-2093091288, "_id"=>"CABCEB3F2C8B70B3FE24A03FF6AB7A1E", "value"=>0}]
  >> pp db.post("_temp_view", "proc { |doc| doc[\"foo\"] =~ /ba/ }").parsed_body["rows"]
  [{"_rev"=>928806717, "_id"=>"28D568C5992CBD2B4711F57225A19517", "value"=>0},
   {"_rev"=>-1696868121, "_id"=>"601D858DB2E298EFC4BBA92A11760D1E", "value"=>0},
   {"_rev"=>-2093091288, "_id"=>"CABCEB3F2C8B70B3FE24A03FF6AB7A1E", "value"=>0}]
   
But you can even do it in plain Ruby, as opposed to a string, with Database#filter:

  >> db.filter do |doc|
  ?>    if doc["foo"] == "bar"
  >>      return doc
  >>    end
  >> end
  => [{"_rev"=>-1696868121, "_id"=>"601D858DB2E298EFC4BBA92A11760D1E", "value"=>{"_id"=>"601D858DB2E298EFC4BBA92A11760D1E", "_rev"=>-1696868121, "foo"=>"bar"}}, {"_rev"=>-2093091288, "_id"=>"CABCEB3F2C8B70B3FE24A03FF6AB7A1E", "value"=>{"_id"=>"CABCEB3F2C8B70B3FE24A03FF6AB7A1E", "_rev"=>-2093091288, "foo"=>"bar"}}]
  
It requires that you set JsServer in your couch.ini to the path of the couch_ruby_view_requestor executable
		
== The Document object

CouchObject::Document wraps a few things in a nice api. In particular you can use it if you don't want to deal with hashes all the time (similar to ActiveRecord and so on):

	>> doc = CouchObject::Document.new({ "foo" => [1,2], "bar" => true  })
	=> #<CouchObject::Document:0x14a7224 @id=nil, @attributes={"foo"=>[1, 2], "bar"=>true}, @revision=nil>
	>> doc["foo"]
	=> [1, 2]
	>> doc.foo
	=> [1, 2]
	>> doc.bar
	=> true
	>> doc.bar?
	=> true
		
You can also save a document to the database:

	>> doc.new?
	=> true
	>> doc.save(db)
	=> #<CouchObject::Response:0x149f358 @response=#<Net::HTTPCreated 201 Created readbody=true>, @parsed_body={"_rev"=>2030456697, "_id"=>"CAEADDC895AC4D506542A3796CCA355D", "ok"=>true}>
	>> doc.id
	=> "CAEADDC895AC4D506542A3796CCA355D"
		
Since CouchObject::Database#get returns a CouchObject::Response object we can convert it into a Document instance easily with CouchObject::Database#to_document:

	>> response = db.get(doc.id)
	=> #<CouchObject::Response:0x1498b98 @response=#<Net::HTTPOK 200 OK readbody=true>, @parsed_body={"_rev"=>2030456697, "_id"=>"CAEADDC895AC4D506542A3796CCA355D", "foo"=>[1, 2], "bar"=>true}>
	>> the_doc_we_just_saved = response.to_document
	=> #<CouchObject::Document:0x148415c @id="CAEADDC895AC4D506542A3796CCA355D", @attributes={"foo"=>[1, 2], "bar"=>true}, @revision=2030456697>
	>> the_doc_we_just_saved.foo
	=> [1, 2]
	>> doc.foo = "quux"
	=> "quux"
	>> doc.save(db)
	=> #<CouchObject::Response:0x4b0adc @response=#<Net::HTTPCreated 201 Created readbody=true>, @parsed_body={"_rev"=>1670064786, "_id"=>"B4077269D2DF8433D145DC0702B9791C", "ok"=>true}>


== CouchObject::Persistable

It all started with this module, it maps ruby objects to CouchDb documents, using two mapping methods. It's highly experimental and may go away n future releases

    gem "couchobject"
    require "couch_object"
    class Bike
      include CouchObject::Persistable

      def initialize(wheels)
        @wheels = wheels
      end
      attr_accessor :wheels

      def to_couch
        {:wheels => @wheels}
      end

      def self.from_couch(attributes)
        new(attributes["wheels"])
      end
    end

By including the CouchObject::Persistable and defining two methods on our class we specify how we should serialize and deserialize our object to and from a CouchDb:

    >> bike_4wd = Bike.new(4)
    => #<Bike:0x6a0a68 @wheels=4>
    >> bike_4wd.save("http://localhost:8888/couchobject")
    => {"_rev"=>1745167971, "_id"=>"6FA2AFB623A93E0E77DEAAF59BB02565", "ok"=>true}
    >> bike = Bike.get_by_id("http://localhost:8888/couchobject", bike_4wd.id)
    => #<Bike:0x64846c @wheels=4>
    

