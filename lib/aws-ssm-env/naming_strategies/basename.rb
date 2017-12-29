require 'aws-ssm-env/naming_strategy'

module AwsSsmEnv
  # 環境変数名にパラメータ名の階層表現のbasenameを利用するようにするNamingStrategy実装クラス。
  # AwsSsmEnv#load で`naming`を指定しなかった場合にはこのクラスのインスタンスが利用される。
  # 例えば、`/path/to/ENV_NAME`というパラメータ名であればENV['ENV_NAME']にパラメータ値がインジェクションされる。
  #
  # @author Ryohei Sonoda
  # @since 0.1.0
  class BasenameNamingStrategy < NamingStrategy
    # @see AwsSsmEnv::NamingStrategy#parse_name
    #
    # パラメータ名の最後の階層を変数名として返す。
    # @return [String] 環境変数名
    def parse_name(parameter)
      File.basename(parameter.name)
    end
  end
end
