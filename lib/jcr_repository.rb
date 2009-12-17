module JCR
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
    
    def clear
      approot.remove
      save
    end
    
    def self.save
      jcr_session.save
    end
    
    def self.path_not_found_exception
      PathNotFoundException
    end
    
    def self.reset
      approot.remove
      jcr_session.save
    end
  end
end