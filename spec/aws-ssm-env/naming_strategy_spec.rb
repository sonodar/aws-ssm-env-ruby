require "spec_helper"

class NameValue
  attr_accessor :name
  def initialize(name)
    @name = name
  end
end

describe AwsSsmEnv::NamingStrategy do

  describe AwsSsmEnv::BasenameNamingStrategy do
    let!(:strategy) { AwsSsmEnv::BasenameNamingStrategy.new }

    it 'environment name should be basename of parameter name' do
      expect(strategy.parse_name(NameValue.new('/path/to/ENVIRONMENT_NAME'))).to eq('ENVIRONMENT_NAME')
      expect(strategy.parse_name(NameValue.new('ENVIRONMENT_NAME'))).to eq('ENVIRONMENT_NAME')
      expect(strategy.parse_name(NameValue.new('/path/to/environment.name'))).to eq('environment.name')
    end

  end

end
