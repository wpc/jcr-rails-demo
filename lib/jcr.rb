if RUBY_PLATFORM == 'java'
  require 'java'
  require 'jcr/jackrabbit-standalone-1.6.0'
  
  module JCR
    autoload :SessionMiddleware, 'jcr/session_middleware'
  end
end