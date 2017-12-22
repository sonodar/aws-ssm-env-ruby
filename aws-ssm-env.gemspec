require File.expand_path('../lib/aws-ssm-env/version', __FILE__)

Gem::Specification.new 'aws-ssm-env', AwsSsmEnv::VERSION do |gem|
  gem.authors       = ['Ryohei Sonoda']
  gem.email         = ['ryohei-sonoda@m3.com']
  gem.description   = gem.summary = 'Loads environment variables from AWS EC2 System Parameters.'
  gem.homepage      = 'https://github.com/m3dev/aws-ssm-env'
  gem.license       = 'MIT'

  gem.files         = `git ls-files README.md LICENSE lib`.split($OUTPUT_RECORD_SEPARATOR)

  gem.add_dependency 'aws-sdk-ssm'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop', '~>0.40.0'
  gem.add_development_dependency 'simplecov'
end
