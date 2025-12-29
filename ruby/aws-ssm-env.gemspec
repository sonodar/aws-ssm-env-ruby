require File.expand_path('lib/aws-ssm-env/version', __dir__)

Gem::Specification.new do |spec|

  spec.name          = 'aws-ssm-env'
  spec.version       = AwsSsmEnv::VERSION
  spec.summary       = spec.description = 'Set parameters acquired from AWS EC2 Parameter Store as environment variables.'

  spec.homepage      = 'https://github.com/sonodar/aws-ssm-env-ruby'
  spec.authors       = [ 'Ryohei Sonoda' ]
  spec.email         = [ 'ryohei-sonoda@m3.com' ]
  spec.license       = 'Apache-2.0'

  spec.files         = Dir.chdir(__dir__) do
    Dir.glob('{lib/**/*,README.md,README_ja.md,CHANGELOG.md,LICENSE}')
  end
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'
  spec.metadata = {
    'source_code_uri' => 'https://github.com/sonodar/aws-ssm-env-ruby/tree/master/ruby',
    'changelog_uri'   => 'https://github.com/sonodar/aws-ssm-env-ruby/tree/master/ruby/CHANGELOG.md'
  }

  spec.add_dependency 'aws-sdk-ssm', '~>1'

  spec.add_development_dependency 'rake', '~> 13.1.0'
  spec.add_development_dependency 'rspec', '~> 3.12.0'
  spec.add_development_dependency 'rubocop', '~> 1.60.2'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.26.1'
  spec.add_development_dependency 'simplecov', '~> 0.16.1'
  spec.add_development_dependency 'simplecov-console', '~> 0.9.1'

end
