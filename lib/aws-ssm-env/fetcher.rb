require 'aws-sdk-ssm'

module AwsSsmEnv
  # AWSのParameter Storeからパラメータを取得するための基底抽象クラス。Iteratorパターンを実装。
  # このクラスのサブクラスは`fetch`メソッドを実装する必要がある。
  # 実装クラスを AwsSsmEnv#load の引数に渡すことによりパラメータの取得方法を切り替えられるようにする。
  #
  # @abstract
  # @author Ryohei Sonoda
  # @since 0.1.0
  class Fetcher
    # ここの引数は AwsSsmEnv#load の呼び出し時に渡された引数がそのまま渡される。
    # 実装クラスによって`args`の内容は変化するが、decryption, client, ssm_client_args は全サブクラス共通。
    #
    # @param [Hash] args AwsSsmEnv#load の呼び出し時に渡された引数。
    # @option args [Boolean] :decryption
    #   <optional> SecureStringパラメータを復号化するかどうか。デフォルトはtrue(復号化する)。
    # @option args [Aws::SSM::Client] :client
    #   <optional> Aws::SSM::Clientのインスタンス。
    #   指定されなかった場合は`ssm_client_args`を引数にして Aws::SSM::Client#new される。
    # @option args [Hash] :ssm_client_args
    #   Aws::SSM::Client#new を実行するときの引数。
    #
    # @see http://docs.aws.amazon.com/sdk-for-ruby/v3/api/index.html
    def initialize(**args)
      @client = create_ssm_client(**args)
      @with_decryption = with_decryption?(**args)
    end

    # Iteratorパターンを実装したメソッド。AwsSsmEnv#load から呼び出される。
    # 実際のパラメータ取得はサブクラスで実装された fetch メソッドで行う。
    # @yield [consumer] 取得したパラメータを受け取って処理を行うブロック引数。
    # @yieldparam [Aws::SSM::Types::Parameter] parameter パラメータ
    def each
      next_token = nil
      loop do
        response = fetch(next_token)
        next_token = response.next_token
        response.parameters.each do |p|
          yield(p)
        end
        if next_token.nil?
          break
        end
      end
    end

    protected

    # Parameter Storeの値を取得するメソッド。サブクラスでOverrideする。
    # 戻り値は AwsSsmEnv::FetchResult と同等の構造でなければいけない。
    #
    # @abstract
    # @param [String] _next_token
    #   NextTokenが必要な場合に渡される。
    #   利用するAPIによっては１回で取得可能なものもあるので(GetParameters)、
    #   このパラメータを利用するかどうかはサブクラスの実装に任せる。
    # @return [AwsSsmEnv::FetchResult] パラメータの配列とNextToken
    def fetch(_next_token)
      raise NotImplementedError, 'fetch'
    end

    # @return [Boolean] SecureStringを復号化するかどうかのフラグ。
    # サブクラスからのみアクセスを許可するため`attr_reader`は使わない。
    def with_decryption
      @with_decryption
    end

    # @return [Aws::SSM::Client] aws-sdkのSSMクライアントインスタンス。
    # サブクラスからのみアクセスを許可するため`attr_reader`は使わない。
    def client
      @client
    end

    private

    def with_decryption?(decryption: 'true', **)
      if decryption.nil?
        true
      elsif decryption.to_s.downcase == 'true'
        true
      else
        false
      end
    end

    def create_ssm_client(client: nil, ssm_client_args: {}, **)
      if client.is_a?(Aws::SSM::Client)
        client
      else
        Aws::SSM::Client.new(ssm_client_args)
      end
    end
  end

  # parametersとnext_tokenを持った値オブジェクト。
  # Fetcerサブクラスのfetchメソッド戻り値として利用する。
  #
  # @attr_reader [Array] parameters
  #   name, value プロパティを持ったパラメータオブジェクトの配列。配列要素の実装クラスは実行されるAPIによって変わる。
  # @attr_reader [String] next_token
  #   １回ですべてのパラメータが取得できないAPIを利用する場合に次の値を取得するためのトークン文字列。
  #   だいたいのAWSのAPIには用意されているため、戻り値の型であるこのクラスに持たせる。
  #
  # @author Ryohei Sonoda
  # @since 0.1.0
  class FetchResult
    attr_reader :parameters, :next_token

    def initialize(parameters, next_token = nil)
      @parameters = parameters
      @next_token = next_token
    end

    EMPTY = new([])
  end
end
