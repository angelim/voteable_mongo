require 'rubygems'
require 'bundler'
Bundler.setup

# start spec with:
# ADAPTOR=mongomapper to setup MongoMapper environment
# Defaults to Mongoid
# eg: ADAPTOR=MongoMapper rspec spec/voteable_mongo/

if ENV["ADAPTOR"] && ENV["ADAPTOR"].downcase == "mongomapper"
  puts 'MongoMapper'
  require 'mongo_mapper'
  models_folder = File.join(File.dirname(__FILE__), 'mongo_mapper/models')
  MongoMapper.database = 'voteable_mongo_test'
else
  puts 'Mongoid'
  require 'mongoid'
  models_folder = File.join(File.dirname(__FILE__), 'mongoid/models')
  Mongoid.configure do |config|
    name = 'voteable_mongo_test'
    host = 'localhost'
    config.master = Mongo::Connection.new.db(name)
    config.autocreate_indexes = true
  end
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))


require 'voteable_mongo'
require 'rspec'
require 'rspec/autorun'

Dir[ File.join(File.dirname(__FILE__),"support/**/*.rb")].each {|f| require f}

Dir[ File.join(models_folder, '*.rb') ].each { |file|
  require file
  file_name = File.basename(file).sub('.rb', '')
  klass = file_name.classify.constantize
  klass.collection.drop
}
RSpec.configure do |config|
  config.include Helpers
end
