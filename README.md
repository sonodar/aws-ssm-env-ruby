[![Build Status](https://travis-ci.org/sonodar/aws-ssm-env-ruby.svg?branch=master)](https://travis-ci.org/sonodar/aws-ssm-env-ruby)
[![Coverage Status](https://coveralls.io/repos/github/sonodar/aws-ssm-env-ruby/badge.svg?branch=master)](https://coveralls.io/github/sonodar/aws-ssm-env-ruby?branch=master)
[![Gem Version](https://badge.fury.io/rb/aws-ssm-env.svg)](https://badge.fury.io/rb/aws-ssm-env)

# aws-ssm-env

This tool sets parameters acquired from `AWS EC2 Parameter Store` as environment variables.  

By default, the last hierarchy of the parameter name is
set as the environment variable name.  

For example, if the parameter name is `/staging/secure/DB_PASSWORD`,
the parameter value is set to `ENV['DB_PASSWORD']`.  
The naming of environment variables is optional and can be customized.
(described later)

## Installation

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

First of all, register the parameters in `AWS EC2 Parameter Store`.

```shell
# ex) register /myservice/staging/RDS_PASSWORD with SecureString
aws ssm --region ap-northeast-1 put-parameter \
  --name /myservice/staging/RDS_PASSWORD \
  --type SecureString --value <secret value>
```

Then, set authentication information of AWS.   
For example, you can use environment variables as follows,

```shell
export AWS_ACCESS_KEY_ID=YOURACCESSKEYID
export AWS_SECRET_ACCESS_KEY=YOURSECRETKEY
bundle exec rails start
```

Or, you can pass `ssm_client_args` as the argument for `AwsSsmEnv#load`:

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

You can also use `Aws.config`.

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

For details, refer to the document of aws-sdk.

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

IAM users who run tests need the following authorization policy:

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

Here are descriptions of the options passed to `AwsSsmEnv#load`.

### decryption: [Boolean]

Flag indicating whether to decrypt SecureString parameters.  
If `true` is specified, the value of the acquired SecureString parameter is decrypted.  
In case of `false` it is set as encrypted and environment variable value.  
Since it is a gem for this, the default is `true` (decrypt).

### overwrite: [Boolean]

Specify whether to overwrite an already set environment variable.  
If `true` is specified, even if the environment variable is set,
it overwrites it with the acquired parameter value.  
If `false` is specified, do not overwrite already set environment variables.  
The default is `false` (do not overwrite).  
If you invoke `AwsSsmEnv#load!`, This flag will automatically be set to `true`.

### client: [Aws::SSM::Client]

Specify an instance of `Aws::SSM::Client`.  
An option to set it if there are already created instances.  
If there are no instances created, use `ssm_client_args` instead.

### ssm_client_args: [Hash]

Specify a hash to pass to the constructor of `Aws::SSM::Client`.  
If not specified, `Aws::SSM::Client#new` is called with an empty argument.  
It is unnecessary when using environment variable
or authentication information by `EC2 InstanceProfile`.

### fetch: [Symbol, AwsSsmEnv::Fetcher, Object]

Specify parameter fetch strategy.  
Possible values are `:path`,`:begins_with`
or an instance of a class that implements `AwsSsmEnv::Fetcher`,
or an instance of a class with a `each` method.  
If nothing is specified, it is treated as `:path`.  
But when `begins_with` (which is described later) is specified,
it will automatically be `:begins_with`.

#### `:fetch => :path` or default

When `:path` is specified, `AwsSsmEnv::PathFetcher` which fetches
parameter hierarchy by path specification is used.  
In this case, the `path` argument described below is required.
Also, the `recursive` argument (described later) is used.  
When acquiring parameters in this way, you need `ssm:GetParametersByPath` authority
for the specified path.  
An example of the IAM policy is shown below.

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

If `:begins_with` is specified, `AwsSsmEnv::BeginsWithFetcher` is used to fetch
parameters starting from the character string specified by the parameter name.  
In this case, the `begins_with` argument described below is required.  
When acquiring parameters in this way,
you need the authority of `ssm:DescribeParameters` and `ssm:GetParameters`
for the specified path.  
An example of the IAM policy is shown below.

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

If you specify an instance of a class that implements `AwsSsmEnv::Fetcher` in` fetch`,
or an instance with a `each` method, that instance will be used as is.

### naming: [Symbol, AwsSsmEnv::NamingStrategy, Object]

Specify the naming strategy for the environment variable name.  
Possible values are `:basename`,`:snakecase`
or an instance of a class that implements `AwsSsmEnv::NamingStrategy`,
or an instance of a class with a `parse_name` method.  
If nothing is specified, it is treated as `:basename`.

#### `:naming => :basename` or default

If `naming` is not specified or `:basename` is specified,
`AwsSsmEnv::BasenameNamingStrategy` whose variable name is
the last hierarchy of the parameter hierarchy is used.  
In this case, for example, if the parameter name is `/myapp/production/DB_PASSWORD`,
the parameter value is set to `ENV['DB_PASSWORD']`. 

#### `:naming => :snakecase`

When `:snakecase` is specified, `AwsSsmEnv::SnakeCaseNamingStrategy` which uses
the underscore delimiter of the parameter name's slash delimiter and converts
it to uppercase letters as the environment variable name is used.  
In this case, for example, if the parameter name is `/myapp/production/DB_PASSWORD`,
the parameter value is set to `ENV['MYAPP_PRODUCTION_DB_PASSWORD']`.  
You can specify first part of string to exclude with
the `removed_prefix` argument described below.
In addition, you can specify characters to be converted to
underscores with the `delimiter` option described below.  
In the following example, the parameter `/myapp/production/db.password` is
set to `ENV['DB_PASSWORD']`.

```ruby
AwsSsmEnv.load!(
  naming: :snakecase,
  removed_prefix: '/myapp/production',
  delimiter: /[\/.]/
)
```

#### other

If you specify an instance of a class that implements `AwsSsmEnv::NamingStrategy` in` fetch`,
or an instance with a `parse_name` method, that instance is used as is.


### path: [String]

Required if nothing is specified for `fetch` or if `:path` is specified.  
This option specifies the path hierarchy for acquiring parameters from `Parameter Store`.  
In the example below, the parameter immediately under `/myapp/web/production` is acquired.

```ruby
AwsSsmEnv.load(path: '/myapp/web/production')
```

#### recursive: [Boolean]

Used when no parameter is specified for `fetch` option or when `:path` is specified.  
If true is specified, acquires all parameters below the specified path hierarchy.  
If nothing is specified this parameter, it is treated as `false`(one level).  
In the following example, all parameters below `/myapp/web/production` are acquired.

```ruby
AwsSsmEnv.load(path: '/myapp/web/production', recursive: true)
```

### begins_with: [String, Array<String>]

Required if `:begins_with` is specified in `fetch`.  
You can specify the prefix of the parameter name to be acquired by this option.  
It is also possible to specify more than one in an array (OR condition).  
In the example below, parameters with names starting with `myapp.web.production` are acquired.

```ruby
AwsSsmEnv.load(path: 'myapp.web.production')
```

### removed_prefix: [String]

Used when `:snakecase` is specified in `naming`.  
By this option, you can specify the prefix of the parameter name to exclude
from the environment variable name.  
If `:removed_ prefix` is not specified, and `:begins_with` or `:path` is specified, that will be used.

### delimiter: [String, Regexp]

Used when `:snakecase` is specified in `naming`.  
By this option, you can specify a string or a regular expression to be converted to an underscore.  
The default is a slash (`/`).

### fetch_size: [Integer]

Specify the number of parameters to be acquired with one execution of AWS API.  
If `:path` is specified, the maximum value is `10` and the default is `10`.  
If `:begins_with` is specified, the maximum value is `50` and the default is `50`.  
Usually this parameter is never specified.
  
## Security

Because you must grant authority to acquire secret information,
careful attention is required for security operation.


When the `EC2 InstanceProfile` is set, the parameters can be seen by any account on EC2,
It is necessary to improve the security level by preparing an IAM User separately
from the `EC2 InstanceProfile`.

If it is only the administrator that you can log in to EC2, 
it is not much different from having it in a file.

Since `AWS Fargate` makes it difficult to execute commands on containers,
this risk is mitigated.

## License

Apache License 2.0

## Contributors

- Ryohei Sonoda <[sonodar](https://github.com/sonodar)>
