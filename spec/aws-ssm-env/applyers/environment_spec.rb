require 'spec_helper'
require 'aws-ssm-env/applyers/environment'

describe AwsSsmEnv::EnvironmentApplyer do
  describe 'apply' do
    it "should not overwrite existing environment variables" do
      ENV['foo'] = nil
      ENV['fizz'] = 'fizz'

      applyer = described_class.new
      applyer.apply('foo', 'bar')
      applyer.apply('fizz', 'buzz')

      expect(ENV['foo']).to eq('bar')
      expect(ENV['fizz']).to eq('fizz')
    end
  end

  describe 'apply!' do
    it "should overwrite existing environment variables" do
      ENV['foo'] = nil
      ENV['fizz'] = 'fizz'

      applyer = described_class.new
      applyer.apply!('foo', 'bar')
      applyer.apply!('fizz', 'buzz')

      expect(ENV['foo']).to eq('bar')
      expect(ENV['fizz']).to eq('buzz')
    end
  end

end
