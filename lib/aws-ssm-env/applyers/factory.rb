require 'aws-ssm-env/applyer'

module AwsSsmEnv
  class ApplyerFactory
    ENV_APPLYER = :environment
    SETTINGS_APPLYER = :settings

    class << self
      def create_applyer(**args)
        scope_type = args[:scope]
        case scope_type
        when nil
          default_applyer(args)
        when ENV_APPLYER
          create_environment_applyer(args)
        when SETTINGS_APPLYER
          create_settings_applyer(args)
        else
          unless applyer_instance?(scope_type)
            raise ArgumentError, 'Possible values for :apply are either :environment, :settings, "OpenStruct" implementation class.'
          end
          scope_type
        end
      end

      private

      def default_applyer(**args)
        create_environment_applyer(args)
      end

      def create_environment_applyer(**args)
        require 'aws-ssm-env/applyers/environment'
        AwsSsmEnv::EnvironmentApplyer.new(args)
      end

      def create_settings_applyer(**args)
        require 'aws-ssm-env/applyers/settings'
        AwsSsmEnv::SettingsApplyer.new(args)
      end

      def applyer_instance?(object)
        if object.is_a?(OpenStruct)
          true
        else
          false
        end
      end
    end
  end
end
