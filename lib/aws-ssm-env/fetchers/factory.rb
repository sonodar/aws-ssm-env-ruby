require 'aws-ssm-env/fetcher'

module AwsSsmEnv
  # Parameter Storeからパラメータを取得するためのクラスを取得もしくは生成するファクトリクラス。
  #
  # @author Ryohei Sonoda
  # @since 0.1.0
  class FetcherFactory
    PATH_FETCHER = :path
    BEGINS_WITH_FETCHER = :begins_with

    class << self
      # Parameter Storeからパラメータを取得するためのクラスを取得もしくは生成する。
      #
      # @param [Hash] args AwsSsmEnv#load に渡された引数がそのまま渡される。
      # @option args [Symbol, AwsSsmEnv::Fetcher, Object] fetch
      #   引数の詳細は AwsSsmEnv#load の説明を参照。
      def create_fetcher(**args)
        fetch_type = args[:fetch]
        case fetch_type
        when nil
          default_fetcher(**args)
        when PATH_FETCHER
          create_path_fetcher(**args)
        when BEGINS_WITH_FETCHER
          create_begins_with_fetcher(**args)
        else
          unless fetcher_instance?(fetch_type)
            raise ArgumentError, 'Possible values for :fetch are either :path, :begins_with, ' \
                + '"AwsSsmEnv::Fetcher" implementation class, an object with "each" method.'
          end
          fetch_type
        end
      end

      private

      def default_fetcher(**args)
        if args.key?(:begins_with)
          create_begins_with_fetcher(**args)
        else
          create_path_fetcher(**args)
        end
      end

      def create_path_fetcher(**args)
        require 'aws-ssm-env/fetchers/path'
        AwsSsmEnv::PathFetcher.new(**args)
      end

      def create_begins_with_fetcher(**args)
        require 'aws-ssm-env/fetchers/begins_with'
        AwsSsmEnv::BeginsWithFetcher.new(**args)
      end

      def fetcher_instance?(object)
        if object.is_a?(AwsSsmEnv::Fetcher)
          true
        elsif object.respond_to?(:each)
          true
        else
          false
        end
      end
    end
  end
end
