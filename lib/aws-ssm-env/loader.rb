require 'aws-ssm-env/fetchers/factory'
require 'aws-ssm-env/naming_strategies/factory'
require 'aws-ssm-env/applyers/factory'

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
        @logger.debug("#{self.class.name} overwrite: #{@overwrite}")
        @logger.debug("#{self.class.name} fetcher: #{@fetcher}")
        @logger.debug("#{self.class.name} naming_strategy: #{@naming_strategy}")
        @logger.debug("#{self.class.name} applyer: #{@applyer}")
      end
    end

    def load
      @fetcher.each do |parameter|
        var_name = @naming_strategy.parse_name(parameter)
        @logger.debug("#{self.class.name} #{parameter.name} parameter value into ENV['#{var_name}']") if @logger
        @applyer.send(@apply_method, var_name, parameter.value)
      end
    end

    private

    def parse_options(**options)
      @logger = options[:logger]
      @fetcher = AwsSsmEnv::FetcherFactory.create_fetcher(options)
      @naming_strategy = AwsSsmEnv::NamingStrategyFactory.create_naming_strategy(options)
      @applyer = AwsSsmEnv::ParameterSetter.new(options)
      @overwrite = overwrite?(options)
      if @overwrite
        @apply_method = :apply!
      else
        @apply_method = :apply
      end
    end

    # overwriteフラグが指定されているかどうかを返す。
    def overwrite?(overwrite: nil, **)
      if overwrite.nil?
        false
      else
        overwrite.to_s.downcase == 'true'
      end
    end

  end
end
