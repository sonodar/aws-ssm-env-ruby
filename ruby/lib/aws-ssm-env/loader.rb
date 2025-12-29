require 'aws-ssm-env/fetchers/factory'
require 'aws-ssm-env/naming_strategies/factory'

module AwsSsmEnv
  # このgemのエントリポイントとなるクラス。メイン処理を行う。
  # AWS EC2 Parameters Storeからパラメータを取得してENVに書き込む。
  #
  # @author Ryohei Sonoda
  # @since 0.1.0
  class Loader
    # メイン処理。引数の詳細は AwsSsmEnv#load を参照。
    def self.load(**args)
      new(**args).load
    end

    def initialize(**args)
      parse_options(**args)
      if @logger
        @logger.debug("#{self.class.name} overwrite: #{@overwrite}")
        @logger.debug("#{self.class.name} fetcher: #{@fetcher}")
        @logger.debug("#{self.class.name} naming_strategy: #{@naming_strategy}")
      end
    end

    def load
      @fetcher.each do |parameter|
        var_name = @naming_strategy.parse_name(parameter)
        @logger&.debug("#{self.class.name} #{parameter.name} parameter value into ENV['#{var_name}']")
        send(@applier, var_name, parameter.value)
      end
    end

    private

    def parse_options(**options)
      @logger = options[:logger]
      @fetcher = AwsSsmEnv::FetcherFactory.create_fetcher(**options)
      @naming_strategy = AwsSsmEnv::NamingStrategyFactory.create_naming_strategy(**options)
      @overwrite = overwrite?(**options)
      if @overwrite
        @applier = :apply!
      else
        @applier = :apply
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
