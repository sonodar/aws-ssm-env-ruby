require 'spec_helper'

describe AwsSsmEnv::NamingStrategy do
  describe '#parse_name' do
    let!(:strategy) { described_class.new }

    it 'raise error' do
      expect { strategy.parse_name(Parameter.new('foo')) }.to raise_error(NotImplementedError)
    end
  end
end
