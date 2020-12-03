require 'aws-ssm-env/naming_strategy'

module AwsSsmEnv
  # 環境変数名を導出するためのNamingStrategyクラスを取得もしくは生成するファクトリクラス。
  #
  # @author Ryohei Sonoda
  # @since 0.1.0
  class NamingStrategyFactory
    BASENAME_STRATEGY = :basename
    SNAKE_CASE_STRATEGY = :snakecase

    class << self
      # 環境変数名を導出するためのNamingStrategyクラスを取得もしくは生成する。
      #
      # @param [Hash] args AwsSsmEnv#load に渡された引数がそのまま渡される。
      # @option args [Symbol, AwsSsmEnv::NamingStrategy, Object] naming
      #   引数の詳細は AwsSsmEnv#load の説明を参照。
      def create_naming_strategy(**args)
        naming_strategy = args[:naming]
        if naming_strategy.nil?
          return default_strategy(**args)
        end
        case naming_strategy
        when BASENAME_STRATEGY
          create_basename_strategy(**args)
        when SNAKE_CASE_STRATEGY
          create_snakecase_strategy(**args)
        else
          unknown_naming_strategy(naming_strategy)
        end
      end

      private

      def default_strategy(**args)
        create_basename_strategy(**args)
      end

      def create_basename_strategy(**args)
        require 'aws-ssm-env/naming_strategies/basename'
        AwsSsmEnv::BasenameNamingStrategy.new(**args)
      end

      def create_snakecase_strategy(**args)
        require 'aws-ssm-env/naming_strategies/snakecase'
        AwsSsmEnv::SnakeCaseNamingStrategy.new(**args)
      end

      def unknown_naming_strategy(naming_strategy)
        unless naming_strategy_instance?(naming_strategy)
          raise ArgumentError, 'Possible values for :naming are either :basename, :snakecase, ' \
                + '"AwsSsmEnv::NamingStrategy" implementation class, an object with "parse_name" method.'
        end
        naming_strategy
      end

      def naming_strategy_instance?(object)
        if object.is_a?(AwsSsmEnv::NamingStrategy)
          true
        elsif object.respond_to?(:parse_name)
          true
        else
          false
        end
      end
    end
  end
end
