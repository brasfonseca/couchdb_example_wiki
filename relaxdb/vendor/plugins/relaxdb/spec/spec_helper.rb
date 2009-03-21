begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'relaxdb'

def setup_test_db
  # RelaxDB.configure :host => "localhost", :port => 5984, :design_doc => "spec_doc", :logger => Logger.new(STDOUT)
  RelaxDB.configure :host => "localhost", :port => 5984, :design_doc => "spec_doc"
  
  RelaxDB.delete_db "relaxdb_spec" rescue "ok"
  RelaxDB.use_db "relaxdb_spec"
  begin
    RelaxDB.replicate_db "relaxdb_spec_base", "relaxdb_spec"
    RelaxDB.enable_view_creation
  rescue
    puts "Run rake create_base_db before the first spec run"
    exit!
  end
end

def create_test_db params = {}
  defaults = {:host => "localhost", :port => 5984, :design_doc => "spec_doc"}
  RelaxDB.configure defaults.merge(params)

  RelaxDB.delete_db "relaxdb_spec" rescue "ok"
  RelaxDB.use_db "relaxdb_spec"  
  RelaxDB.enable_view_creation
end

def create_base_db
  RelaxDB.configure :host => "localhost", :port => 5984, :design_doc => "spec_doc"
  RelaxDB.delete_db "relaxdb_spec_base" rescue "ok"
  RelaxDB.use_db "relaxdb_spec_base"
  RelaxDB.enable_view_creation
  require File.dirname(__FILE__) + '/spec_models.rb'
  puts "Created relaxdb_spec_base"
end
