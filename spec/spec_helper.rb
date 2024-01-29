if ENV['CI']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  require 'simplecov-console'
  SimpleCov.start do
    add_filter '/vendor/'
    add_filter '/spec/'
    SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::Console,
    ]
  end
end

require 'aws-ssm-env'
require 'aws_ssm_env/parameter'

RSpec.configure do |config|
  config.filter_run_excluding(integration: true)
end
