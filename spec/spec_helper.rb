unless ENV['DISABLE_COVERAGE']
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
require 'aws-ssm-env/parameter'
RSpec.configure do |config|
  config.filter_run_excluding integration: true
end
