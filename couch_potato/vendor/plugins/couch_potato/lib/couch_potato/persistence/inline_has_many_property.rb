class InlineHasManyProperty
  attr_accessor :name
  
  def initialize(owner_clazz, name, options = {})
    @name = name
    getter =  <<-GETTER
      def #{name}
        @#{name} ||= CouchPotato::Persistence::InlineCollection.new(#{item_class_name})
      end
    GETTER
    owner_clazz.class_eval getter
  end
  
  def build(object, json)
    object.send("#{name}").clear
    json[name.to_s].each do |item|
      item.delete 'ruby_class'
      object.send("#{name}").build item
    end
  end
  
  def dirty?(object)
    object.send("#{name}").dirty?
  end
  
  def save(object)
    
  end
  
  def serialize(json, object)
    json[name.to_s] = object.send(name)
  end
  
  def destroy(object)
    
  end
  
  private
  
  def item_class_name
    @name.to_s.singularize.camelcase
  end
end