$KCODE = 'u'
require 'jcode'

require "rubygems"
gem "json"
begin
  require "json/ext"
rescue LoadError
  $stderr.puts "C version of json (fjson) could not be loaded, using pure ruby one"
  require "json/pure"
end

require 'json/add/core'
require "ruby2ruby"

$:.unshift File.dirname(__FILE__)

require "couch_object/utils"
require "couch_object/proc_condition"
require "couch_object/document"
require "couch_object/response"
require "couch_object/server"
require "couch_object/database"
require "couch_object/view"
require "couch_object/persistable"
require "couch_object/model"

module CouchObject
  
end