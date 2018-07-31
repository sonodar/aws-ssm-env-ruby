require 'spec_helper'

describe AwsSsmEnv::Applyer do
  let(:applyer) { described_class.new(args) }
  let(:args) { {} }

  describe '#apply' do
    let!(:applyer) { described_class.new }
    it 'raise error' do
      expect { applyer.apply(Parameter.new('foo'), Parameter.new('bar')) }.to raise_error(NotImplementedError)
    end
  end

  describe '#apply!' do
    let!(:applyer) { described_class.new }
    it 'raise error' do
      expect { applyer.apply!(Parameter.new('foo'), Parameter.new('bar')) }.to raise_error(NotImplementedError)
    end
  end

end