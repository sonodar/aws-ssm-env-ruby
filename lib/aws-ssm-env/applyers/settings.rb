require 'aws-ssm-env/applyer'

module AwsSsmEnv
  class SettingsApplyer < Applyer
    def apply(name, value)
      if Settings[name]
        return
      end
      apply!(name, value)
    end

    def apply!(name, value)
      Settings[name] = value
    end
  end
end
