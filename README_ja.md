[![Build Status](https://travis-ci.org/sonodar/aws-ssm-env-ruby.svg?branch=master)](https://travis-ci.org/sonodar/aws-ssm-env-ruby)
[![Coverage Status](https://coveralls.io/repos/github/sonodar/aws-ssm-env-ruby/badge.svg?branch=master)](https://coveralls.io/github/sonodar/aws-ssm-env-ruby?branch=master)
[![Gem Version](https://badge.fury.io/rb/aws-ssm-env.svg)](https://badge.fury.io/rb/aws-ssm-env)

# aws-ssm-env

AWS EC2 Parameter Storeから取得したパラメータを環境変数として設定します。  

デフォルトでは、パラメータ名の最後の階層が環境変数名として設定されます。  

例えば、`/staging/secure/DB_PASSWORD`というパラメータ名であれば、`ENV['DB_PASSWORD']`にパラメータ値が設定されます。  
この環境変数のネーミングはオプションでカスタマイズ可能です。(後述)

## Installation

このgemはRuby2.2から2.5まででテストされています。

```
gem install aws-ssm-env
```

### Rails

```ruby
# Gemfile
gem 'aws-ssm-env', group: :aws
```

```ruby
# config/application.rb
if defined?(AwsSsmEnv)
  AwsSsmEnv.load(path: "/myapp/#{ENV['RAILS_ENV']}", recursive: true)
end
```

### Other ruby program

```ruby
require 'aws-ssm-env'
AwsSsmEnv.load!(begins_with: "myapp.#{ENV['RACK_ENV']}.")
```

## Quick Start

事前にAWS EC2 Parameter Storeにパラメータを登録しておく必要があります。

```shell
# 例) /myservice/staging/RDS_PASSWORDをSecureStringで登録
aws ssm --region ap-northeast-1 put-parameter \
  --name /myservice/staging/RDS_PASSWORD \
  --type SecureString --value <secret value>
```

AWSの認証情報を設定します。例えば、以下のように環境変数を利用したり、

```shell
export AWS_ACCESS_KEY_ID=YOURACCESSKEYID
export AWS_SECRET_ACCESS_KEY=YOURSECRETKEY
bundle exec rails start
```

引数で`ssm_client_args`を渡したり、

```ruby
AwsSsmEnv.load(
  fetch: "/myservice/#{ENV['RAILS_ENV']}",
  ssm_client_args: {
    access_key_id: 'ACCESS_KEY_ID',
    secret_access_key: 'SECRET_ACCESS_KEY',
    region: 'ap-northeast-1',
  }
)
```

`Aws.config`を利用することもできます。

```ruby

if defined?(AwsSsmEnv)
  AWS.config({
    access_key_id: 'ACCESS_KEY_ID',
    secret_access_key: 'SECRET_ACCESS_KEY',
    region: 'ap-northeast-1',
  })
  AwsSsmEnv.load(path: "/myservice/#{ENV['RAILS_ENV']}")
end
```

詳細はaws-sdkのドキュメントを参照してください。

## Develop

### Unit test

```shell
bundle exec rspec
bundle exec rubocop
```

### Integration test

```shell
export AWS_ACCESS_KEY_ID=xxxx
export AWS_SECRET_ACCESS_KEY=xxxx
export AWS_REGION=xxxx
bundle exec rspec --tag integration
```

IAMユーザには以下の認可ポリシーが必要です。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "ssm:PutParameter",
        "ssm:DeleteParameters",
        "ssm:DescribeParameters",
        "ssm:GetParameters*"
      ],
      "Resource": "*"
    }
  ]
}
```


## Usage

`AwsSsmEnv#load`に渡すオプションの説明です。

### decryption: [Boolean]

SecureStringのパラメータを復号化するかどうかを表すフラグ。  
`true`を指定した場合は取得したSecureStringパラメータの値は復号化されている。  
`false`の場合は暗号化されたまた環境変数値として設定される。  
なお、このためのgemなのでデフォルトは`true`(復号化する)。

### overwrite: [Boolean]

すでに設定されている環境変数を上書きするかどうかを指定する。  
`true`を指定した場合、環境変数が設定されていても取得したパラメータ値で上書きする。  
`false`を指定した場合はすでに設定されている環境変数を上書きしない。  
デフォルトは`false`(上書きしない)。  
なお、`AwsSsmEnv#load!`を実行した場合、このフラグは自動的に`true`になる。

### client: [Aws::SSM::Client]

`Aws::SSM::Client`のインスタンスを指定する。  
すでに生成済みのインスタンスがある場合にそれを設定するためのオプション。  
生成済みのインスタンスがない場合は`ssm_client_args`を利用する。

### ssm_client_args: [Hash]

`Aws::SSM::Client`のコンストラクタに渡すハッシュを指定する。  
指定しなかった場合は引数なしで`Aws::SSM::Client.new`が呼ばれる。  
環境変数やEC2インスタンスプロファイルによる認証情報を利用する場合は不要。

### fetch: [Symbol, AwsSsmEnv::Fetcher, Object]

パラメータ取得方法を指定する。  
指定可能な値は`:path`, `:begins_with`または`AwsSsmEnv::Fetcher`を実装したクラスのインスタンス、`each`メソッドを
持ったクラスのインスタンスのいずれか。  
何も指定されていない場合は`:path`として扱われるが、後述の`begins_with`が指定されていた場合は自動的に`:begins_with`となる。

#### `:fetch => :path` or default

`:path`を指定した場合はパラメータ階層をパス指定で取得する`AwsSsmEnv::PathFetcher`が利用される。  
この場合は後述の`path`引数が必須となる。また、後述の`recursive`引数を利用する。  
この方法でパラメータを取得する場合は指定するパスに対して`ssm:GetParametersByPath`の権限が必要。
以下、IAMポリシーの例を示す。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "ssm:GetParametersByPath",
      "Resource": "arn:aws:ssm:YOUR_REGION:YOUR_ACCOUNT_ID:parameter/YOUR_PATH"
    }
  ]
}
```

#### `:fetch => :begins_with`

`:begins_with`を指定した場合はパラメータ名が指定した文字列から開始するパラメータを取得する`AwsSsmEnv::BeginsWithFetcher`が利用される。  
この場合は後述の`begins_with`引数が必須となる。
この方法でパラメータを取得する場合は指定するパスに対して`ssm:DescribeParameters`および`ssm:GetParameters`の権限が必要。
以下、IAMポリシーの例を示す。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "ssm:DescribeParameters",
      "Resource": "arn:aws:ssm:YOUR_REGION:YOUR_ACCOUNT_ID:parameter"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": "ssm:GetParameters",
      "Resource": "arn:aws:ssm:YOUR_REGION:YOUR_ACCOUNT_ID:parameter/YOUR_PREFIX*"
    }
  ]
}
```

#### other

`fetch`に`AwsSsmEnv::Fetcher`を実装したクラスのインスタンス、もしくは`each`メソッドを持つインスタンスを指定した場合はそのインスタンスをそのまま利用する。

### naming: [Symbol, AwsSsmEnv::NamingStrategy, Object]

環境変数名を導出方法を指定する。  
指定可能な値は`:basename`, `:snakecase`または`AwsSsmEnv::NamingStrategy`を実装したクラスのインスタンス、`parse_name`メソッドを持ったクラスのインスタンスのいずれか。  
デフォルトは`:basename`。

#### `:naming => :basename` or default

`naming`を指定しなかった場合、もしくは`:basename`を指定した場合はパラメータ階層の最後の階層を変数名とする`AwsSsmEnv::BasenameNamingStrategy`が利用される。  
この場合、例えば`/myapp/production/DB_PASSWORD`というパラメータ名であれば`ENV['DB_PASSWORD']`にパラメータ値がインジェクションされる。

#### `:naming => :snakecase`

`:snakecase`を指定した場合はパラメータ名のスラッシュ区切りをアンダースコア区切りにした結果を大文字に変換して環境変数名とする`AwsSsmEnv::SnakeCaseNamingStrategy`が利用される。  
この場合、例えば`/myapp/production/DB_PASSWORD`というパラメータ名であれば`ENV['MYAPP_PRODUCTION_DB_PASSWORD']`にパラメータ値がインジェクションされる。  
後述の`removed_prefix`引数で除外する先頭文字列を指定することができる。  
また、後述の`delimiter`オプションでアンダースコアに変換する文字を指定できる。  
以下の例では`/myapp/production/db.password`というパラメータが`ENV['DB_PASSWORD']`にインジェクションされる。

```ruby
AwsSsmEnv.load!(
  naming: :snakecase,
  removed_prefix: '/myapp/production',
  delimiter: /[\/.]/
)
```

#### other

`AwsSsmEnv::NamingStrategy`を実装したクラスのインスタンス、もしくは`parse_name`メソッドを持つ  
インスタンスを指定した場合はそのインスタンスをそのまま利用する。

### path: [String]

`fetch`に何も指定していない場合、もしくは`:path`を指定した場合は必須となる。  
パラメータを取得するパス階層を指定する。  
下の例では`/myapp/web/production`直下のパラメータが取得される。

```ruby
AwsSsmEnv.load(path: '/myapp/web/production')
```

#### recursive: [Boolean]

`fetch`に何も指定していない場合、もしくは`:path`を指定した場合に利用する。  
指定したパス階層以下のパラメータをすべて取得する。  
下の例では`/myapp/web/production`以下すべてのパラメータが取得される。

```ruby
AwsSsmEnv.load(path: '/myapp/web/production', recursive: true)
```

### begins_with: [String, Array<String>]

`fetch`に`:begins_with`を指定した場合は必須となる。  
取得するパラメータ名のプレフィクスを指定する。配列で複数指定することも可能(OR条件となる)。  
下の例では`myapp.web.production`で始まる名前のパラメータが取得される。

```ruby
AwsSsmEnv.load(path: 'myapp.web.production')
```

### removed_prefix: [String]

`naming`に`:snakecase`を指定した場合に利用される。  
環境変数名から除外するパラメータ名のプレフィクスを指定する。  
`:removed_prefix`が指定されておらず、`:begins_with`もしくは`:path`が指定されていた場合はそれを利用する。

### delimiter: [String, Regexp]

`naming`に`:snakecase`を指定した場合に利用される。  
アンダースコアに変換する文字列もしくは正規表現を指定する。  
デフォルトはスラッシュ(`/`)。

### fetch_size: [Integer]

一度のAWS API実行で取得するパラメータ数を指定する。 `:path`指定の場合は最大値は`10`でデフォルトも`10`。  
`:begins_with`指定の場合は最大値は`50`でデフォルトも`50`である。通常このパラメータを指定することはない。


## Motivation

RailsアプリケーションをECSで起動する場合、環境変数を渡すのが面倒だったので作りました。  

## Security

シークレット情報を取得するための権限を付与しなければならないため、セキュリティ運用には十分な注意が必要です。

EC2インスタンスプロファイルが設定されていた場合、そのEC2上であればどのアカウントでもパラメータが見えるようになるため、  
EC2インスタンスプロファイルとは別にIAMユーザを用意するなどセキュリティレベルを上げる工夫が必要です。  

EC2にログインできるのが管理者のみであればファイルで持つのと大差ありません。

`AWS Fargate`であればコンテナ上でコマンドの実行は困難なため、このリスクは軽減されます。

## License

Apache License 2.0

## Contributors

- Ryohei Sonoda <[sonodar](https://github.com/sonodar)>
