require 'aws-ssm-env/fetchers/factory'
require 'aws-ssm-env/naming_strategies/factory'
require 'aws-ssm-env/parameter_setter'

module AwsSsmEnv
  # このgemのエントリポイントとなるクラス。メイン処理を行う。
  # AWS EC2 Parameters Storeからパラメータを取得してENVに書き込む。
  #
  # @author Ryohei Sonoda
  # @since 0.1.0
  class Loader
    # メイン処理。引数の詳細は AwsSsmEnv#load を参照。
    def self.load(**args)
      new(args).load
    end

    def initialize(**args)
      parse_options(args)
      if @logger
        @logger.debug("#{self.class.name} fetcher: #{@fetcher}")
        @logger.debug("#{self.class.name} naming_strategy: #{@naming_strategy}")
        @logger.debug("#{self.class.name} parameter_setter: #{@parameter_setter}")
      end
    end

    def load
      @fetcher.each do |parameter|
        var_name = @naming_strategy.parse_name(parameter)
        @logger.debug("#{self.class.name} #{parameter.name} parameter value into ENV['#{var_name}']") if @logger
        @parameter_setter.save(var_name, parameter.value)
      end
    end

    private

    def parse_options(**options)
      @logger = options[:logger]
      @fetcher = AwsSsmEnv::FetcherFactory.create_fetcher(options)
      @naming_strategy = AwsSsmEnv::NamingStrategyFactory.create_naming_strategy(options)
      @parameter_setter = AwsSsmEnv::ParameterSetter.new(options)
    end
  end
end
