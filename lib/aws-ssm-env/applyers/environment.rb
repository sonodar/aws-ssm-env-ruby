require 'aws-ssm-env/applyer'

module AwsSsmEnv
  class EnvironmentApplyer < Applyer
    def apply(name, value)
      if ENV[name]
        return
      end
      apply!(name, value)
    end

    def apply!(name, value)
      ENV[name] = value
    end
  end
end
