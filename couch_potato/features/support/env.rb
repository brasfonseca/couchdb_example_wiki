# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'
require 'cucumber/formatters/unicode' # Comment out this line if you don't want Cucumber Unicode support


# Comment out the next two lines if you're not using RSpec's matchers (should / should_not) in your steps.
require 'cucumber/rails/rspec'

CouchPotato.couchrest_database.delete! rescue nil
CouchPotato.couchrest_database.create!

Before do
  CouchPotato.couchrest_database.delete! rescue nil
  CouchPotato.couchrest_database.create!
  
end

DB = CouchPotato.database