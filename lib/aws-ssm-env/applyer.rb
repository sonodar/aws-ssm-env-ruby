module AwsSsmEnv
  class Applyer
    def initialize(**); end
    def apply(name, value)
      raise NotImplementedError, 'apply'
    end
    def apply!(name, value)
      raise NotImplementedError, 'apply!'
    end
  end
end
