require 'aws-ssm-env/fetcher'
require 'aws-ssm-env/naming_strategy'

module AwsSsmEnv
  class Loader

    class << self
      def call(**args)
        new(args).call
      end

      def call!(**args)
        new(args.merge(overwrite: true)).call
      end
    end

    def initialize(**args)
      @fetcher = fetcher(args)
      @naming_strategy = naming_strategy(args)
      if overwrite?(args[:overwrite])
        @applier = ->(name, value) { ENV[name] = value }
      else
        @applier = ->(name, value) { ENV[name] ||= value }
      end
    end

    attr_reader :fetcher, :naming_strategy

    def call
      @fetcher.each do |parameter|
        name = @naming_strategy.parse_name(parameter)
        @applier.call(name, parameter.value)
      end
    end

    private

    def fetcher(**args)
      if args[:fetcher].nil?
        AwsSsmEnv::PathFetcher.new(args)
      else
        args[:fetcher]
      end
    end

    def naming_strategy(**args)
      if args[:naming].nil?
        AwsSsmEnv::BasenameNamingStrategy.new
      else
        args[:naming]
      end
    end

    def overwrite?(overwrite)
      !overwrite.nil? && overwrite === true
    end

  end
end
