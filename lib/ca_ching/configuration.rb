module CaChing
  module Configuration
    def configure
      yield self
    end
    
    def cache=(cache)
      @cache = cache
    end
    
    def cache
      @cache 
    end
    
    def disabled?
      @disabled
    end
    
    def disabled=(d)
      @disabled = d
    end
  end
end