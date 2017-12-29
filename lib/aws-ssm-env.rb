require 'aws-ssm-env/loader'
#
# AWS EC2 Parameters Storeからパラメータを取得してENVに書き込むモジュール。
#
# @author Ryohei Sonoda
# @since 0.1.0
module AwsSsmEnv
  module_function

  # メイン処理。EC2 Parameter Storeからパラメータを取得して環境変数にインジェクションする。
  #
  # @param [Hash] args この処理で利用するすべての引数をまとめて渡す。
  #
  # @option args [Boolean] decryption
  #
  #   SecureStringのパラメータを復号化するかどうかを表すフラグ。
  #   `true`を指定した場合は取得したSecureStringパラメータの値は復号化されている。
  #   `false`の場合は暗号化されたまた環境変数値として設定される。
  #   なお、このためのgemなのでデフォルトは`true`(復号化する)。
  #
  # @option args [Boolean] overwrite
  #
  #   すでに設定されている環境変数を上書きするかどうかを指定する。
  #   `true`を指定した場合、環境変数が設定されていても取得したパラメータ値で上書きする。
  #   `false`を指定した場合はすでに設定されている環境変数を上書きしない。
  #   デフォルトは`false`(上書きしない)。
  #   なお、`AwsSsmEnv#load!`を実行した場合、このフラグは自動的に`true`になる。
  #
  # @option args [Aws::SSM::Client] :client
  #
  #   `Aws::SSM::Client`のインスタンスを指定する。
  #   すでに生成済みのインスタンスがある場合にそれを設定するためのオプション。
  #   生成済みのインスタンスがない場合は`ssm_client_args`を利用する。
  #
  # @option args [Hash] :ssm_client_args
  #
  #   `Aws::SSM::Client`のコンストラクタに渡すハッシュを指定する。
  #   指定しなかった場合は引数なしで`Aws::SSM::Client.new`が呼ばれる。
  #   環境変数やEC2インスタンスプロファイルによる認証情報を利用する場合は不要。
  #
  # @option args [Symbol, AwsSsmEnv::Fetcher, Object] :fetch
  #
  #   パラメータ取得方法を指定する。
  #   指定可能な値は`:path`, `:begins_with`または`AwsSsmEnv::Fetcher`を実装したクラスのインスタンス、`each`メソッドを
  #   持ったクラスのインスタンスのいずれか。
  #   何も指定されていない場合は`:path`として扱われるが、後述の`begins_with`が指定されていた場合は自動的に`:begins_with`となる。
  #
  #   `:path`を指定した場合はパラメータ階層をパス指定で取得する`AwsSsmEnv::PathFetcher`が利用される。
  #   この場合は後述の`path`引数が必須となる。また、後述の`recursive`引数を利用する。
  #   この方法でパラメータを取得する場合は指定するパスに対して`ssm:GetParametersByPath`の権限が必要。
  #   以下、IAMポリシーの例を示す。
  #   {
  #     "Version": "2012-10-17",
  #     "Statement": [
  #       {
  #         "Sid": "",
  #         "Effect": "Allow",
  #         "Action": "ssm:GetParametersByPath",
  #         "Resource": "arn:aws:ssm:YOUR_REGION:YOUR_ACCOUNT_ID:parameter/your_path"
  #       }
  #     ]
  #   }
  #
  #   `:begins_with`を指定した場合はパラメータ名が指定した文字列から開始するパラメータを取得する`AwsSsmEnv::BeginsWithFetcher`が利用される。
  #   この場合は後述の`begins_with`引数が必須となる。
  #   この方法でパラメータを取得する場合は指定するパスに対して`ssm:DescribeParameters`および`ssm:GetParameters`の権限が必要。
  #   以下、IAMポリシーの例を示す。
  #   {
  #     "Version": "2012-10-17",
  #     "Statement": [
  #       {
  #         "Sid": "",
  #         "Effect": "Allow",
  #         "Action": "ssm:DescribeParameters",
  #         "Resource": "arn:aws:ssm:YOUR_REGION:YOUR_ACCOUNT_ID:parameter"
  #       },
  #       {
  #         "Sid": "",
  #         "Effect": "Allow",
  #         "Action": "ssm:GetParameters",
  #         "Resource": "arn:aws:ssm:YOUR_REGION:YOUR_ACCOUNT_ID:parameter/your_path/*"
  #       }
  #     ]
  #   }
  #
  #   `fetch`に`AwsSsmEnv::Fetcher`を実装したクラスのインスタンス、もしくは`each`メソッドを持つ
  #   インスタンスを指定した場合はそのインスタンスをそのまま利用する。
  #
  # @option args [Symbol, AwsSsmEnv::NamingStrategy, Object] :naming
  #
  #   環境変数名を導出方法を指定する。
  #   指定可能な値は`:basename`, `:snakecase`または`AwsSsmEnv::NamingStrategy`を実装したクラスのインスタンス、`parse_name`メソッドを持ったクラスのインスタンスのいずれか。
  #   デフォルトは`:basename`。
  #
  #   `naming`を指定しなかった場合、もしくは`:basename`を指定した場合はパラメータ階層の最後の階層を変数名とする`AwsSsmEnv::BasenameNamingStrategy`が利用される。
  #   この場合、例えば`/myapp/production/DB_PASSWORD`というパラメータ名であれば`ENV['DB_PASSWORD']`にパラメータ値がインジェクションされる。
  #
  #   `:snakecase`を指定した場合はパラメータ名のスラッシュ区切りをアンダースコア区切りにした結果を大文字に変換して環境変数名とする`AwsSsmEnv::SnakeCaseNamingStrategy`が利用される。
  #   この場合、例えば`/myapp/production/DB_PASSWORD`というパラメータ名であれば`ENV['MYAPP_PRODUCTION_DB_PASSWORD']`にパラメータ値がインジェクションされる。
  #   後述の`removed_prefix`引数で除外する先頭文字列を指定することができる。
  #   また、後述の`delimiter`オプションでアンダースコアに変換する文字を指定できる。
  #   以下の例では`/myapp/production/db/password`というパラメータが`ENV['DB_PASSWORD']`にインジェクションされる。
  #   > AwsSsmEnv.load(naming: :snakecase, removed_prefix: '/myapp/production')
  #
  #   `AwsSsmEnv::NamingStrategy`を実装したクラスのインスタンス、もしくは`parse_name`メソッドを持つ
  #   インスタンスを指定した場合はそのインスタンスをそのまま利用する。
  #
  # @option args [String] :path
  #
  #   `fetch`に何も指定していない場合、もしくは`:path`を指定した場合は必須となる。
  #   パラメータを取得するパス階層を指定する。
  #   下の例では`/myapp/web/production`直下のパラメータが取得される。
  #   > AwsSsmEnv.load(path: '/myapp/web/production')
  #
  # @option args [Boolean] :recursive
  #
  #   `fetch`に何も指定していない場合、もしくは`:path`を指定した場合に利用する。
  #   指定したパス階層以下のパラメータをすべて取得する。
  #   下の例では`/myapp/web/production`以下すべてのパラメータが取得される。
  #   > AwsSsmEnv.load(path: '/myapp/web/production', recursive: true)
  #
  # @option args [String, Array<String>] :begins_with
  #
  #   `fetch`に`:begins_with`を指定した場合は必須となる。
  #   取得するパラメータ名のプレフィクスを指定する。配列で複数指定することも可能(OR条件となる)。
  #   下の例では`myapp.web.production`で始まる名前のパラメータが取得される。
  #
  #   下の例では 'myapp.web.production' で始まる名前のパラメータが取得される。
  #   irb> AwsSsmEnv.load(path: 'myapp.web.production')
  #
  # @option args [String] :removed_prefix
  #
  #   `naming`に`:snakecase`を指定した場合に利用される。
  #   環境変数名から除外するパラメータ名のプレフィクスを指定する。
  #   `:removed_prefix`が指定されておらず、`:begins_with`もしくは`:path`が指定されていた場合はそれを利用する。
  #
  # @option args [String, Regexp] :delimiter
  #
  #   `naming`に`:snakecase`を指定した場合に利用される。
  #   アンダースコアに変換する文字列もしくは正規表現を指定する。
  #   デフォルトはスラッシュ(`/`)。
  #
  # @option args [Integer] fetch_size
  #
  #   一度のAWS API実行で取得するパラメータ数を指定する。 `:path`指定の場合は最大値は`10`でデフォルトも`10`。
  #   `:begins_with`指定の場合は最大値は`50`でデフォルトも`50`である。通常このパラメータを指定することはない。
  #
  # AwsSsmEnv::Loader#load の委譲メソッド。
  #
  # @see AwsSsmEnv::Loader#load
  def load(**args)
    AwsSsmEnv::Loader.load(args)
  end

  # `overwrite`オプションを付与した AwsSsmEnv::Loader#load の委譲メソッド。
  # @see AwsSsmEnv::Loader#load
  def load!(**args)
    AwsSsmEnv::Loader.load(args.merge(overwrite: true))
  end
end
