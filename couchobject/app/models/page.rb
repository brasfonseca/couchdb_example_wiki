class Page
  include CouchObject::Persistable
  include Validatable
  
  attr_accessor :title, :body, :created_at, :id, :rev
  
  validates_presence_of :title, :body
  
  def initialize(attributes = {})
    self.attributes = attributes
  end
  
  def self.by_created_at(view_options = {})
    by(:created_at, view_options)
  end
  
  def self.by_title(view_options = {})
    by(:title, view_options)
  end
  
  def self.by(attribute, view_options = {})
    path = URI.escape "/_design/pages/_view/by_#{attribute}?" + {:include_docs => true}.merge(view_options).map{|key, value| "#{key}=#{value.to_json}" unless value.blank?}.compact.join('&')
    response = database.get(path)
    raw = if response.code == 404
            design = design_document
            design['views']["by_#{attribute}"] = default_map_function(attribute)
            database.put "/_design/pages", design.to_json
            database.get(path)
          else
            response
          end
    raw.parsed_body['rows'].map{|row| Page.from_couch(row['doc']['attributes'].merge(:id => row['doc']['_id'], :rev => row['doc']['_rev']))}
  end
  
  def to_param
    id
  end
  
  def new_record?
    new?
  end
  
  def save
    return false unless valid?
    response = if new?
      database.post("", to_json)
    else
      database.put(id, to_json)
    end
    if response.code == 201
      self.id = response.parsed_body["id"]
      self.rev = response.parsed_body['rev']
      true
    end
  end
  
  def save!
    save || raise("could not save #{self.inspect}: #{errors.inspect}")
  end
  
  def attributes=(attributes)
    attributes.each do |name, value|
      send("#{name}=", name.to_sym == :created_at ? DateTime.parse(value) : value)
    end
  end
  
  def update_attributes(attributes)
    self.attributes = attributes
    save
  end
  
  #define_callbacks :update
  #update_callback :after, :create_version
  
  #use_database COUCH_DB
  
  # view_by :title
  # view_by :created_at
  
  def to_couch
    {:title => title, :body => body, :created_at => (created_at || Time.now).strftime("%Y/%m/%d %H:%M:%S %z")}
  end
  
  # taken from persistable
  def to_json
    raise NoToCouchMethodError unless respond_to?(:to_couch)
    json = {"class" => self.class, "attributes" => self.to_couch}
    json.merge!('_id' => id) if id
    json.merge!('_rev' => rev) if rev
    json.to_json
  end
  
  
  def self.from_couch(attributes)
    new attributes
  end
  
  # def versions(options = {})
  #     PageVersion.by_version_and_page_id({:startkey => [1, self.id], :endkey => [9999999999, self.id]}.merge(options))
  #   end
  #   
  #   def versions_count
  #     versions(:reduce => true)['rows'].first.try(:[], 'value') || 0
  #   end
  
  
  # def self.word_counts
  #   WordCount.by_count(:reduce => true, :group => true)['rows'].map{|row| [row['key'], row['value']]}
  # end
  
  # def body_with_keep_old=(new_body)
  #   @body_was ||= body
  #   self.send :'body_without_keep_old=', new_body
  # end
  # alias_method_chain :body=, :keep_old
  
  private
  
  def self.design_document
    response = database.get('/_design/pages')
    if response.code == 200
      response.parsed_body
    else
      {'views' => {}}
    end
  end
  
  def self.database
    COUCH_DB
  end
  
  def database
    self.class.database
  end
  
  def self.default_map_function(attribute)
    {
      'map' => "function(doc) {
        if(doc.class == '#{self.name}') {
          emit(doc.attributes['#{attribute}'], null);
        }
      }"
    }
  end
  
  # def create_version
  #   PageVersion.new(:page_id => id, :body => @body_was, :version => versions_count + 1).save!
  #   true
  # end
  
end