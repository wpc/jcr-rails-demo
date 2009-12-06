module JCRRepository
  include_class javax.jcr.Repository
  include_class javax.jcr.Session
  include_class org.apache.jackrabbit.core.TransientRepository
  include_class javax.jcr.SimpleCredentials
  
  def self.jcr_repo
    return @jcr_repo if @jcr_repo
    @jcr_repo = TransientRepository.new
  end
  
  def self.credential
    SimpleCredentials.new("wpc", "pass".to_java_string.to_char_array)
  end
  
  def self.jcr_session
    return Thread.current[:jcr_session] if Thread.current[:jcr_session]
    Thread.current[:jcr_session] = jcr_repo.login(credential) 
  end
end