require 'spec_helper'
require 'aws-ssm-env/applyers/settings'

describe AwsSsmEnv::SettingsApplyer do
  describe 'apply' do
    it "should not overwrite existing environment variables" do
      Settings = OpenStruct.new
      Settings['foo'] = nil
      Settings['fizz'] = 'fizz'

      applyer = described_class.new
      applyer.apply('foo', 'bar')
      applyer.apply('fizz', 'buzz')

      expect(Settings['foo']).to eq('bar')
      expect(Settings['fizz']).to eq('fizz')
    end
  end

  describe 'apply!' do
    it "should overwrite existing environment variables" do
      Settings['foo'] = nil
      Settings['fizz'] = 'fizz'

      applyer = described_class.new
      applyer.apply!('foo', 'bar')
      applyer.apply!('fizz', 'buzz')

      expect(Settings['foo']).to eq('bar')
      expect(Settings['fizz']).to eq('buzz')
    end
  end

end
