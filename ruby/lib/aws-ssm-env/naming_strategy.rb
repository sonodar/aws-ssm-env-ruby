module AwsSsmEnv
  # パラメータの値を設定する環境変数名を決定するためのStrategyクラス。
  # 実装クラスを AwsSsmEnv#load の引数で`naming`パラメータとして渡すことにより
  # インジェクションされる環境変数名の命名ルールを切り替えられるようにする。
  #
  # @abstract
  # @author Ryohei Sonoda
  # @since 0.1.0
  class NamingStrategy
    # ここの引数は AwsSsmEnv#load の呼び出し時に渡された引数がそのまま渡される。
    # サブクラスでは必要に応じて使う引数をインスタンス変数に保持しておく。
    #
    # @param [Hash] ** AwsSsmEnv#load の呼び出し時に渡された引数。
    def initialize(**); end

    # パラメータから環境変数名を導出するメソッド。
    # @abstract
    # @return [String] 環境変数名
    def parse_name(_parameter)
      raise NotImplementedError, 'parse_name'
    end
  end
end
