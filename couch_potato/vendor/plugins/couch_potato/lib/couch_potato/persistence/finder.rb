require 'uri'

module CouchPotato
  module Persistence
    class Finder
      # finds all objects of a given type by the given attribute/value pairs
      # options: attribute_name => value pairs to search for
      # value can also be a range which will do a range search with startkey/endkey
      # WARNING: calling this methods creates a new view in couchdb if it's not present already so don't overuse this
      def find(clazz, conditions = {}, view_options = {})
        to_instances clazz, ViewQuery.new(design_document(clazz), view(conditions), map_function(clazz, search_fields(conditions)), count_reduce_function, conditions, view_options.merge(:include_docs => true, :reduce => false)).query_view!
      end
      
      def count(clazz, conditions = {}, view_options = {})
        ViewQuery.new(design_document(clazz), view(conditions), map_function(clazz, search_fields(conditions)), count_reduce_function, conditions, view_options.merge(:include_docs => false, :reduce => true)).query_view!['rows'].first.try(:[], 'value') || 0
      end
      
      private
      
      def db(name = nil)
        ::CouchPotato::Persistence.Db(name)
      end
      
      def design_document(clazz)
        clazz.name.underscore
      end
      
      def map_function(clazz, search_fields)
        "function(doc) {
          if(doc.ruby_class == '#{clazz}') {
            emit([#{search_fields.map{|attr| "doc[\"#{attr}\"]"}.join(', ')}], null);
          }
        }"
      end
      
      def count_reduce_function
        "function(keys, values, combine) {
          if (combine) {
            return sum(values);
          } else {
            return values.length;
          }
        }"
      end
      
      def to_instances(clazz, query_result)
        query_result['rows'].map{|doc| doc['doc']}.map{|json| clazz.json_create json}
      end
      
      def view(conditions)
        "by_#{view_name(conditions)}"
      end
      
      def search_fields(conditions)
        conditions.to_a.sort_by{|f| f.first.to_s}.map(&:first)
      end
      
      def view_name(options)
        options.to_a.sort_by{|f| f.first.to_s}.map(&:first).join('_and_')
      end
    end
  end
end