require File.expand_path('../lib/aws-ssm-env/version', __FILE__)

Gem::Specification.new 'aws-ssm-env', AwsSsmEnv::VERSION do |gem|
  gem.authors       = ['Ryohei Sonoda']
  gem.email         = ['ryohei-sonoda@m3.com']
  gem.description   = gem.summary = 'Loads environment variables from AWS EC2 System Parameters.'
  gem.homepage      = 'https://github.com/sonodar/aws-ssm-env-ruby'
  gem.license       = 'Apache License 2.0'

  gem.files         = `git ls-files README.md README_en.md LICENSE lib`.split($OUTPUT_RECORD_SEPARATOR)

  gem.add_dependency 'aws-sdk-ssm', '~>1'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop', '~>0.48.1'
  gem.add_development_dependency 'rubocop-rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'simplecov-console'
end
