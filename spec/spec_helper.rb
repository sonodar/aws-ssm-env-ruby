require 'simplecov'
SimpleCov.start do
  add_filter '/vendor/'
  add_filter '/spec/'
end

require 'aws-ssm-env'
RSpec.configure do |config|
  # Restore the state of ENV after each spec
  config.before { @env_keys = ENV.keys }
  config.after  { ENV.delete_if { |k, _v| !@env_keys.include?(k) } }
end
