require 'aws-ssm-env/fetcher'

module AwsSsmEnv
  # Parameter Storeのパス階層を利用したFetcherクラスの実装サブクラス。
  # `path`と`recursive`を指定してパス階層のパラメータ値をまとめて取得する。
  # `ssm:GetParametersByPath`の認可が必要。
  #
  # @author Ryohei Sonoda
  # @since 0.1.0
  class PathFetcher < Fetcher
    MAX_FETCH_SIZE = 10

    # @see AwsSsmEnv::Fetcher#initialize
    #
    # @param [Hash] args AwsSsmEnv#load の呼び出し時に渡された引数。
    # @option args [String] :path <required> 取得するパラメータのパス。
    # @option args [Boolean] :recursive <optional> サブパスのパラメータまで取得するかどうか。デフォルトはfalse(pathの階層のみ)。
    # @option args [Integer] :fetch_size <optional> 一度のAPI実行で取得するパラメータ数。最大10。デフォルトは10。
    def initialize(**args)
      super
      @base_params = base_params(args)
    end

    protected

    # @see AwsSsmEnv::Fetcher#fetch
    #
    # 指定したパス階層配下のパラメータを取得する。
    # @see http://docs.aws.amazon.com/systems-manager/latest/APIReference/API_GetParametersByPath.html
    def fetch(next_token)
      params = fetch_params(next_token)
      client.get_parameters_by_path(params)
    end

    private

    def base_params(path: nil, recursive: 'false', fetch_size: 10, **)
      if path.nil?
        raise ArgumentError, 'path is required.'
      end
      {
        path: path,
        recursive: recursive?(recursive),
        with_decryption: with_decryption,
        max_results: detect_max_results(fetch_size)
      }.freeze
    end

    def recursive?(recursive)
      if recursive.to_s.downcase == 'true'
        true
      else
        false
      end
    end

    def detect_max_results(fetch_size)
      if fetch_size.nil?
        MAX_FETCH_SIZE
      elsif fetch_size.to_i > 10
        MAX_FETCH_SIZE
      else
        fetch_size.to_i
      end
    end

    def fetch_params(next_token)
      if next_token.nil?
        @base_params
      else
        @base_params.merge(next_token: next_token)
      end
    end
  end
end
