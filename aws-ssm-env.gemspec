require File.expand_path('../lib/aws-ssm-env/version', __FILE__)

Gem::Specification.new do |spec|

  spec.name          = 'aws-ssm-env'
  spec.version       = AwsSsmEnv::VERSION
  spec.summary       = spec.description = 'Set parameters acquired from AWS EC2 Parameter Store as environment variables or Rails Settings.'

  spec.homepage      = 'https://github.com/sonodar/aws-ssm-env-ruby'
  spec.authors       = [ 'Ryohei Sonoda' ]
  spec.email         = [ 'ryohei-sonoda@m3.com' ]
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files README.md README_ja.md CHANGELOG.md LICENSE lib`.split($OUTPUT_RECORD_SEPARATOR)
  spec.test_files    = `git ls-files spec`.split($OUTPUT_RECORD_SEPARATOR)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2'
  spec.metadata = {
    'source_code_uri' => 'https://github.com/sonodar/aws-ssm-env-ruby',
    'changelog_uri'   => 'https://github.com/sonodar/aws-ssm-env-ruby/tree/master/CHANGELOG.md'
  }

  spec.add_dependency 'aws-sdk-ssm', '~>1'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop', '~>0.48.1'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-console'

end
