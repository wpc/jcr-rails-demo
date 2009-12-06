require 'benchmark'

module JCRRecord
  include_class javax.jcr.PathNotFoundException
  
  class Errors
    include Enumerable
  
    def each(&block)
      [].each(&block)
    end
    def size
      0
    end
    alias_method :count, :size
    alias_method :length, :size
  end
  
  class Base
    def self.all
      class_root.nodes.collect do |node|
        create_from_jcr_node(node)
      end
    end
    
    def self.create_from_jcr_node(node)
      returning(self.new) { |record| record.jcr_node = node }
    end
    
    def self.find(id)
      create_from_jcr_node(class_root.get_node(jcr_name(id)))
    end
    
    def self.add_node
      id = generate_id
      jcr_node = class_root.add_node(jcr_name(id))
      jcr_session.save
      jcr_node
    end
    
    def self.delete_node(jcr_node)
      jcr_node.remove
      jcr_session.save
    end
    
    def self.jcr_name(id)
      "i#{id}"
    end

    def self.jcr_session
      JCRRepository.jcr_session
    end
    
    def self.class_root
      root = jcr_session.root_node
      begin
        root.get_node(self.name)
      rescue PathNotFoundException
        root.add_node(self.name)
      end
    end
    
    # todo: need a safer sequence if used not as a toy
    def self.generate_id
      begin
        last = class_root.get_property("sequence").get_long
      rescue PathNotFoundException
        last = 0
      end      
      class_root.set_property("sequence", last + 1)
      last + 1
    end

    def initialize(attributes={})
      attributes ||= {}
      @attributes = attributes.clone
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
    
    def id
      @jcr_node && @jcr_node.name.scan(/\d+/)[0].to_i
    end
    
    def to_param  # make resource routing happy
      (id = self.id) ? id.to_s : nil
    end
    
    def save
      if new_record?
        self.jcr_node = self.class.add_node
        true
      else
        raise 'dud, implement it first'
      end
    end
    
    def destroy
      self.class.delete_node(@jcr_node)
      self.freeze
    end
  end
end

class Item < JCRRecord::Base
end