module JCR
  class QueryResult
    include Enumerable
    
    def initialize(resultset, model_class)
      @resultset = resultset
      @model_class = model_class
    end
    
    def size
      to_a.size
    end
    
    def to_a
      super.uniq
    end
    
    def each(&block)
      @resultset.nodes.each do |n|
        yield @model_class.create_from_jcr_node(n)
      end
    end
    
  end
  
  module Repository
    include_class javax.jcr.Repository
    include_class javax.jcr.Session
    include_class org.apache.jackrabbit.core.TransientRepository
    include_class javax.jcr.SimpleCredentials
    include_class javax.jcr.NoSuchWorkspaceException
    include_class javax.jcr.PathNotFoundException
  
    def self.ns
      @ns || "myapp"
    end
  
    def self.ns=(namespace)
      @ns = namespace
    end
  
    def self.jcr_repo
      return @jcr_repo if @jcr_repo
      @jcr_repo = TransientRepository.new("config/repository.xml", "db/repository")
    end
  
    def self.credential
      SimpleCredentials.new("wpc", "pass".to_java_string.to_char_array)
    end
  
    def self.jcr_session
      return Thread.current[:jcr_session] if Thread.current[:jcr_session]
      Thread.current[:jcr_session] = jcr_repo.login(credential, RAILS_ENV)
    rescue NoSuchWorkspaceException
      jcr_repo.login(credential).workspace.create_workspace(RAILS_ENV)
      retry
    end
  
    def self.node_types
      node_type_manager.all_node_types.reject { |t| t.name !~ /^#{ns}:.*/ }
    end
  
    def self.node_type_manager
      jcr_session.workspace.node_type_manager
    end
    
    def self.find_or_create_node(name)
      begin
        approot.get_node(name)
      rescue PathNotFoundException
        approot.add_node(name)
      end
    end
    
    def self.approot
      begin
        root_node.get_node(ns)
      rescue PathNotFoundException
        root_node.add_node(ns)
      end      
    end
    
    def self.root_node
      jcr_session.root_node
    end
    
    def self.save
      jcr_session.save
    end
    
    def self.path_not_found_exception
      PathNotFoundException
    end
    
    def self.reset
      approot.remove
      save
    end
    
    def self.qf
      jcr_session.workspace.query_manager.getQOMFactory()
    end
    
    def self.query(constrain, model_class)
      q = qf.create_query(qf.selector("nt:base"), constrain, nil, nil)
      QueryResult.new(q.execute, model_class)
    end
    
  end
end