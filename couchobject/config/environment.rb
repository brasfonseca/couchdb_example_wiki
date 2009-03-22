# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.1' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.gem 'validatable'

  config.frameworks -= [ :active_record, :active_resource ]
  config.time_zone = 'UTC'
end

COUCH_DB = CouchObject::Database.open("http://localhost:5984/wiki_example_couchobject_#{RAILS_ENV}")
