# aws-ssm-env

AWS EC2 Parameter Storeから取得したパラメータを環境変数として設定します。  

デフォルトでは、パラメータ名の最後の階層が環境変数名として設定されます。  

例えば、`/staging/secure/DB_PASSWORD`というパラメータ名であれば、`ENV['DB_PASSWORD']`にパラメータ値が設定されます。  
この環境変数のネーミングはオプションでカスタマイズ可能です。(後述)

## Installation

### Rails

```ruby
# Gemfile
gem 'aws-ssm-env'
```

```ruby
# config/application.rb
if defined?(AwsSsmEnv::Loader)
  AwsSsmEnv::Loader.call(path: "/#{ENV['RAILS_ENV']}", decryption: true)
end
```

### Other ruby program

```ruby
require 'aws-ssm-env'
AwsSsmEnv::Loader.call(path: '/prefix', overwrite: true)
```

## Usage

AWSの認証情報を設定します。例えば、以下のように環境変数を利用したり、

```shell
export AWS_ACCESS_KEY_ID=YOURACCESSKEYID
export AWS_SECRET_ACCESS_KEY=YOURSECRETKEY
bundle exec rails start
```

引数で`ssm_client_args`を渡したり、

```ruby
AwsSsmEnv::Loader.call(path: "/#{ENV['RAILS_ENV']}", decryption: true, ssm_client_args: {
  access_key_id: 'ACCESS_KEY_ID',
  secret_access_key: 'SECRET_ACCESS_KEY',
  region: 'ap-northeast-1',
})

```

`Aws.Config`を利用することもできます。

```ruby

AWS.config({
  access_key_id: 'ACCESS_KEY_ID',
  secret_access_key: 'SECRET_ACCESS_KEY',
  region: 'ap-northeast-1',
})
if defined?(AwsSsmEnv::Loader)
  AwsSsmEnv::Loader.call(path: "/#{ENV['RAILS_ENV']}", decryption: true)
end
```

詳細はaws-sdkのドキュメントを参照してください。

実行するIAMユーザもしくはEC2インスタンスプロファイルには以下の権限が必要です。  
実際に利用するのは今のところ`ssm:GetParametersByPath`だけですが、今後の拡張で`GetParameters`や`GetParameter`も利用する可能性があるため`GetParameter*`としています。  
権限を与えすぎないように`Resource`でパスまで指定することを推奨します。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "ssm:GetParameter*",
      "Resource": "arn:aws:ssm:ap-northeast-1:999999999999:parameter/prefix/*"  
    }
  ]
}

```

## Options

### path (string)

Parameter Storeのパラメータを検索する階層です。  
`/`から始まる必要があります。デフォルトは`/`です。

### recursive (bool)

階層を再帰的に検索するかどうかのフラグです。  
`true`を指定した場合、`path`で指定した階層のサブパスまで検索します。  
デフォルトは`false`(`path`で指定した階層のみ)です。

### overwrite (bool)

すでにある環境変数を上書きするかどうかのフラグです。  
`true`を指定した場合、プロセスの環境変数をParameter Storeの値で上書きします。  
デフォルトは`false`です。

`overwrite`を指定しなくても上書きするための`call!`メソッドもあります。  
挙動としては、`call(overwrite: true)`と全く同じです。

### decryption (bool)

Parameter Storeのパラメータのタイプが`SecureString`の値を復号化するかどうかのフラグです。  
`true`を指定した場合、環境変数の値には復号化された値が格納されます。  
このためにあるgemなので、デフォルトが`true`です。

### fetch_size (int)

一度のAPIコールで取得するパラメータの個数で最大値は`10`です。デフォルトは`10`です。  
通常、この値を指定する必要はありません。


### filters (Array)

`Aws::SSM::Client#get_parameters_by_path`の`parameter_filters`引数に渡されるフィルタ条件の配列です。  
詳細は`aws-sdk-ruby`の[ドキュメント](http://docs.aws.amazon.com/sdkforruby/api/Aws/SSM/Types/ParameterStringFilter.html)を御覧ください。  
デフォルトは空です。

### ssm_client_args (Hash)

`Aws::SSM::Client.new`に渡される引数です。独自の認証情報を渡す場合や、エンドポイント、リージョンなどを指定する場合に使います。  
デフォルトは`{}`で、認証情報には環境変数やEC2インスタンスプロファイルが利用されます。

### naming (AwsSsmEnv::NamingStrategy)

環境変数名をカスタマイズする場合に指定します。`parse_name(parameter)`というメソッドが実装されたインスタンスであれば何を指定しても問題ありません。  
引数の`parameter`には通常、[Aws::SSM::Types::GetParametersByPathResult](http://docs.aws.amazon.com/sdkforruby/api/Aws/SSM/Types/GetParametersByPathResult.html)が渡されます。  
`fetcher`を指定している場合は`fetcher`の`each`メソッドでブロックに渡す値が引数になります。  
デフォルトは`AwsSsmEnv::BasenameNamingStrategy`のインスタンスです。

以下は`naming`の実装例です。

```ruby
# パラメータ名をスネークケースに変換する(prefixを除去)
naming_strategy = Class.new {
  def parse_name(parameter)
    parameter.name.gsub(/\A\/staging/, '').gsub(/\//, '_')
  end
}.new
AwsSsmEnv::Loader.call(path: '/staging', naming: naming_strategy)
```

### fetcher (AwsSsmEnv::Fetcher)

独自のパラメータ取得処理を使う場合に指定します。パラメータの取得方法を細かく制御したい場合に利用します。  
`each`メソッドが実装されたインスタンスであれば何を指定しても問題ありませんが、`AwsSsmEnv::Fetcher`を継承したクラスであれば`fetch`メソッドを実装するだけですみます。  
`each`メソッドの中でブロックに渡す引数は`name`と`value`というプロパティを持っている必要があります。  
デフォルトは`ssm:GetParametersByPath`を利用した`AwsSsmEnv::PathFetcher`のインスタンスが利用されます。

`AwsSsmEnv::Fetcher`の実装は以下のようになっています。

```ruby
# 文脈に無関係なコードは割愛しています
module AwsSsmEnv
  class Fetcher
    def each
      fetch!
      until eos?
        fetch! if needs_fetch?
        yield(@parameters[@current_index])
        @current_index += 1
      end
    end

    protected

    def fetch; end

    def fetch!
      results = self.fetch
      @parameters = results.parameters
      @next_token = results.next_token
      @current_index = 0
    end
  end
end
```
