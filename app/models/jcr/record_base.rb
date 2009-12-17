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
      update_node(jcr_node, attributes)
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
      repo.find_or_create_node(self.name)
    end
    
    def self.property(name, type=:string)
      property_definitions[name] = type
    end
    
    def self.property_definitions
      @property_definitions ||= {}
    end
    
    def self.create(attributes={})
      record = new(attributes)
      record.save
      record
    end
    
    attr_accessor :jcr_node

    def initialize(attributes={})
      attributes ||= {}
      @attributes = attributes.clone
    end
    
    def set_attribute(name, value)
      @attributes[name] = value
    end
    
    def attribute(name)
      if @attributes.has_key?(name)
        return @attributes[name]
      end

      begin
        jcr_node.get_property(name.to_s).string
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
    
    def save
      if new_record?
        raise 'you must give a identifier to the record' unless identifier
        self.jcr_node = self.class.add_node(identifier, @attributes)
      else
        self.class.update_node(jcr_node, @attributes)
      end
      @attributes = {}
      true
    end
    
    def destroy
      self.class.delete_node(@jcr_node)
      self.freeze
    end
    
    def ==(another)
      self.jcr_node && another.jcr_node && self.jcr_node.path == another.jcr_node.path
    end
  end
end