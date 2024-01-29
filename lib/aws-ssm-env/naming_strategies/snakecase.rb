require 'aws-ssm-env/naming_strategy'

module AwsSsmEnv
  # パラメータ名の階層表現をスネークケースに変換した値を環境変数名とする。
  # 例えば、`removed_prefix`が`/path`で`/path/to/environment_name`というパラメータ名なら
  # ENV['TO_ENVIRONMENT_NAME']にパラメータ値がインジェクションされる。
  #
  # @author Ryohei Sonoda
  # @since 0.1.0
  class SnakeCaseNamingStrategy < NamingStrategy
    # ここの引数は AwsSsmEnv#load の呼び出し時に渡された引数がそのまま渡される。
    #
    # @param [Hash] args AwsSsmEnv#load の呼び出し時に渡された引数。
    # @option args [String] :removed_prefix
    #   パラメータ名から除去するプレフィクス。この文字列は導出される環境変数名に含まない。
    #   :removed_prefixが指定されておらず、:begins_with または :path が指定されていた場合はそれを利用する。 TODO: AwsSsmEnv#loadとREADMEに反映
    # @option args [String, Regexp] :delimiter
    #   アンダースコアに変換する区切り文字。デフォルトはスラッシュ('/')。 TODO: AwsSsmEnv#loadとREADMEに反映
    def initialize(**args)
      super
      @logger = args[:logger]
      @delimiter = detect_delimiter(**args)
      removed_prefix = detect_prefix(**args).sub(%r{/\z}, '')
      @removed_prefix = /\A#{Regexp.escape(removed_prefix)}/
      @logger&.debug("#{self.class.name} removed_prefix is #{@removed_prefix}")
    end

    # @see AwsSsmEnv::NamingStrategy#parse_name
    #
    # パラメータ名からプレフィクスを除去してパス区切りをアンダースコアに変換後、大文字にして返す。
    # @return [String] 環境変数名
    def parse_name(parameter)
      name_without_prefix = parameter.name.gsub(@removed_prefix, '')
      name_without_prefix.gsub(@delimiter, '_').upcase
    end

    private

    def detect_delimiter(**args)
      if args[:delimiter].nil?
        '/'
      else
        args[:delimiter]
      end
    end

    def detect_prefix(**args)
      if args[:removed_prefix]
        args[:removed_prefix]
      elsif args[:begins_with]
        args[:begins_with]
      elsif args[:path]
        args[:path]
      else
        ''
      end
    end
  end
end
