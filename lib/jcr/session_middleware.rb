module JCR
  class SessionMiddleware
    def initialize(app)
      @app = app  
    end  
    
    def call(env)
      Thread.current[:jcr_sessions] = nil
      begin
        @app.call(env)
      ensure
        Thread.current[:jcr_sessions].logout if Thread.current[:jcr_sessions]
        Thread.current[:jcr_sessions] = nil
      end
    end
  end
end