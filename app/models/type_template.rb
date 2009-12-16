class TypeTemplate
  attr_accessor :name
  
  def errors
    JCR::Errors.new
  end
end