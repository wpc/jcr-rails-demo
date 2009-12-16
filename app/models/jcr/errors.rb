module JCR
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
end