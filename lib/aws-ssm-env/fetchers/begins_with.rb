require 'aws-ssm-env/fetcher'

module AwsSsmEnv
  # パラメータ名の前方一致で取得するFetcherクラスの実装サブクラス。
  # `begins_with`で指定した文字列で始まるパラメータ名に一致するパラメータを取得する。
  # [`ssm:DescribeParameters`, `ssm:GetParameters`]の認可が必要。
  #
  # @author Ryohei Sonoda
  # @since 0.1.0
  class BeginsWithFetcher < Fetcher
    MAX_FETCH_SIZE = 50
    BASE_FILTER = { key: 'Name', option: 'BeginsWith' }.freeze

    # @param [Hash] args AwsSsmEnv#load の呼び出し時に渡された引数。
    # @option args [String] :begins_with <required> パラメータ名の開始文字列。この文字列が前方一致するパラメータを取得する。
    # @option args [Integet] :fetch_size <optional> 一度のAPI実行で取得するパラメータ数。最大50。デフォルトは50。
    def initialize(**args)
      super
      @base_params = base_params(**args)
    end

    protected

    # @see AwsSsmEnv::Fetcher#fetch
    #
    # パラメータ名による検索はGetParametersByPathのような便利なAPIはないため、DescribeParametersでパラメータ名による
    # 前方一致検索をしてからGetParametersでパラメータの値を取得している。
    # @see http://docs.aws.amazon.com/systems-manager/latest/APIReference/API_DescribeParameters.html
    # @see http://docs.aws.amazon.com/systems-manager/latest/APIReference/API_GetParameters.html
    def fetch(next_token)
      params = fetch_params(next_token)
      response = client.describe_parameters(params)
      if response.parameters.empty?
        AwsSsmEnv::FetchResult::EMPTY
      else
        parameters = get_parameters(response.parameters)
        AwsSsmEnv::FetchResult.new(parameters, response.next_token)
      end
    end

    private

    def base_params(begins_with: nil, fetch_size: '50', **)
      if begins_with.nil?
        raise ArgumentError, ':begins_with is required.'
      end
      {
        parameter_filters: to_parameter_filters(begins_with),
        max_results: detect_max_results(fetch_size)
      }.freeze
    end

    def detect_max_results(fetch_size)
      if fetch_size.nil?
        MAX_FETCH_SIZE
      elsif fetch_size.to_i > MAX_FETCH_SIZE
        MAX_FETCH_SIZE
      else
        fetch_size.to_i
      end
    end

    def to_parameter_filters(begins_with)
      values = Array(begins_with)
      [ BASE_FILTER.merge(values: values) ]
    end

    def fetch_params(next_token)
      if next_token.nil?
        @base_params
      else
        @base_params.merge(next_token: next_token)
      end
    end

    def get_parameters(parameters)
      response = client.get_parameters(
        names: parameters.map(&:name),
        with_decryption: with_decryption
      )
      response.parameters
    end
  end
end
