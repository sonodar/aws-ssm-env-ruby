require 'spec_helper'
require 'aws-ssm-env/naming_strategies/basename'

describe AwsSsmEnv::BasenameNamingStrategy do
  describe '#parse_name' do
    let(:naming_strategy) { described_class.new }

    it 'return the last element name of the path hierarchy' do
      expect(naming_strategy.parse_name(Parameter.new('/path/to/ENV_NAME'))).to eq('ENV_NAME')
      expect(naming_strategy.parse_name(Parameter.new('env_name'))).to eq('env_name')
      expect(naming_strategy.parse_name(Parameter.new('env/name'))).to eq('name')
    end
  end
end
