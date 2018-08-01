require 'spec_helper'

describe AwsSsmEnv::Loader do
  let(:args) { { path: '/foo' } }

  describe '#initialize' do
    let(:loader) { described_class.new(args) }

    it 'has fetcher and naming_strategy' do
      expect(loader.instance_variable_get(:@fetcher)).to be_a(AwsSsmEnv::PathFetcher)
      expect(loader.instance_variable_get(:@naming_strategy)).to be_a(AwsSsmEnv::BasenameNamingStrategy)
      expect(loader.instance_variable_get(:@parameter_setter)).to be_a(AwsSsmEnv::ParameterSetter)
    end
  end

  describe '#load' do
    let(:loader) { described_class.new(args) }

    it 'parses the parameter name' do
      expect(loader.instance_variable_get(:@naming_strategy)).to respond_to(:parse_name).with(1).argument
      expect(loader.instance_variable_get(:@parameter_setter)).to respond_to(:save).with(2).argument
    end
  end
end
