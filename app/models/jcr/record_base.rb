module JCR
  
  class RecordBase
    def self.all
      class_root.nodes.collect do |node|
        create_from_jcr_node(node)
      end
    end
    
    def self.create_from_jcr_node(node)
      returning(self.new) { |record| record.jcr_node = node }
    end
    
    def self.find(identifier)
      create_from_jcr_node(class_root.get_node(identifier))
    end
    
    def self.add_node(identifier, attributes={})
      jcr_node = class_root.add_node(identifier)
      jcr_node.add_mixin("mix:versionable") if @versionable
      update_node(jcr_node, attributes)
    end
    
    def self.add_child(parent_node, attributes)
      attributes =  attributes.with_indifferent_access
      identifier = attributes[:identifier]
      raise 'must give identifier field' unless identifier
      
      child_node = parent_node.add_node(identifier)
      update_node(child_node, attributes)
    end
    
    def self.update_node(jcr_node, attributes)
      attributes.each do |key, value|
        jcr_node.set_property(key.to_s, value)
      end
      repo.save
      jcr_node
    end
    
    def self.delete_node(jcr_node)
      jcr_node.remove
      repo.save
    end
    
    def self.repo
      JCR::Repository
    end
    
    def self.class_root
      repo.find_or_create_node(class_root_name)
    end
    
    def self.class_root_name
      self.name.underscore.pluralize
    end
    
    def self.has_property(name, type=:string)
      property_definitions[name] = type
      evaluate_attribute_method "def #{name}; read_attribute('#{name}'); end"
      evaluate_attribute_method "def #{name}=(new_value);write_attribute('#{name}', new_value);end"
      if type == :boolean
        evaluate_attribute_method "def #{name}?; read_attribute('#{name}'); end"
      end
    end
    
    def self.versionable
      @versionable = true
    end
    
    def self.property_definitions
      @property_definitions ||= {}.with_indifferent_access
    end
    
    def self.create(attributes={})
      record = new(attributes)
      record.save
      record
    end
    
    # Evaluate the definition for an attribute related method
    def self.evaluate_attribute_method(method_definition)
      class_eval(method_definition, __FILE__, __LINE__)
    end
    
    def self.search(search_exp)
      repo.query(
        repo.qf.send(:and,
          repo.qf.descendant_node(class_root.path),
          repo.qf.full_text_search('name', search_exp)), self)
    end
    
    attr_accessor :jcr_node

    def initialize(attributes={})
      attributes ||= {}
      @attributes = attributes.with_indifferent_access
    end
    
    def write_attribute(name, value)
      @attributes[name] = value
    end
    
    def read_attribute(name)
      if @attributes.has_key?(name)
        return @attributes[name]
      end
      
      return if new_record?
      type = self.class.property_definitions[name]
      begin
        jcr_node.get_property(name.to_s).send(type)
      rescue self.class.repo.path_not_found_exception
        nil
      end
    end
    
    def jcr_node= (jcr_node)
      @jcr_node = jcr_node
    end
  
    def errors
      Errors.new
    end

    def new_record?
      @jcr_node == nil
    end
    
    def identifier
      return @attributes[:identifier] if @attributes.has_key?(:identifier)
      @jcr_node && @jcr_node.name
    end
    
    def to_param  # make resource routing happy
      identifier
    end
    
    def update_attributes(attrs)
      attrs.each do |key, value|
        write_attribute(key, value)
      end
      save
    end
    
    def save
      if new_record?
        raise 'you must give a identifier to the record' unless identifier
        self.jcr_node = self.class.add_node(identifier, @attributes)
      else
        self.class.update_node(jcr_node, @attributes)
      end
      @attributes = {}.with_indifferent_access
      true
    end
    
    def destroy
      self.class.delete_node(@jcr_node)
      self.freeze
    end
    
    def ==(another)
      self.jcr_node && another.jcr_node && self.jcr_node.path == another.jcr_node.path
    end
    
    def eql?(another)
      self == another
    end
    
    def hash
      (jcr_node && jcr_node.path).hash
    end
    
    def checkin
      raise 'need save a node first before checkin' unless jcr_node
      jcr_node.checkin
    end
    
    def checkout
      raise 'need save a node first before checkout' unless jcr_node
      jcr_node.checkout
    end
    
    def restore(version)
      jcr_node.restore(version, true)
    end
    
    def versions
      jcr_node.version_history.all_versions.to_a
    end
    
    def add_child(attributes)
      self.class.create_from_jcr_node(self.class.add_child(jcr_node, attributes))
    end
    
    def children
      jcr_node.nodes.collect do |n|
        self.class.create_from_jcr_node(n)
      end
    end
  end
end