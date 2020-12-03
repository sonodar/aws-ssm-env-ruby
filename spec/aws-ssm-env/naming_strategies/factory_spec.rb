require 'spec_helper'

describe AwsSsmEnv::NamingStrategyFactory do
  describe '#create_naming_strategy' do
    let(:naming_strategy) { described_class.create_naming_strategy(**args) }

    context 'when naming was not set' do
      let(:args) { { naming: nil } }

      it 'return AwsSsmEnv::BasenameNamingStrategy' do
        expect(naming_strategy).to be_a(AwsSsmEnv::BasenameNamingStrategy)
      end
    end

    context 'when naming is :basename' do
      let(:args) { { naming: :basename } }

      it 'return AwsSsmEnv::BasenameNamingStrategy' do
        expect(naming_strategy).to be_a(AwsSsmEnv::BasenameNamingStrategy)
      end
    end

    context 'when naming is :snakecase' do
      let(:args) { { naming: :snakecase } }

      it 'return AwsSsmEnv::SnakeCaseNamingStrategy' do
        expect(naming_strategy).to be_a(AwsSsmEnv::SnakeCaseNamingStrategy)
      end
    end

    context 'when naming is AwsSsmEnv::NamingStrategy implementation instance' do
      let(:naming_class) { Class.new(AwsSsmEnv::NamingStrategy) { def parse_name(_); end } }
      let(:naming_instance) { naming_class.new }
      let(:args) { { naming: naming_instance } }

      it 'return it as is' do
        expect(naming_strategy).to eq(naming_instance)
      end
    end

    context 'when naming has parse_name method' do
      let(:naming_class) { Class.new { def parse_name(_); end } }
      let(:naming_instance) { naming_class.new }
      let(:args) { { naming: naming_instance } }

      it 'return it as is' do
        expect(naming_strategy).to eq(naming_instance)
      end
    end

    context 'in other cases' do
      it 'raise error' do
        expect { described_class.create_naming_strategy(naming: 'foo') }.to raise_error(ArgumentError)
      end
    end
  end
end
