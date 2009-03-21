# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION


# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.frameworks -= [ :active_record, :active_resource ]
  config.time_zone = 'UTC'
end

RelaxDB.configure :host => "localhost", :port => 5984, :design_doc => 'wiki'
RelaxDB.use_db "wiki_example_relaxdb_#{RAILS_ENV}"
RelaxDB.enable_view_creation

