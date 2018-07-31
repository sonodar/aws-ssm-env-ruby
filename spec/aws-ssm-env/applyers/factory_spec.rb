require 'spec_helper'

describe AwsSsmEnv::ApplyerFactory do
  describe '#create_applyer' do
    let(:applyer) { described_class.create_applyer(args) }

    context 'when apply_type was not set' do
      let(:args) { { scope: nil } }

      it 'return AwsSsmEnv::EnvironmentApplyer' do
        expect(applyer).to be_a(AwsSsmEnv::EnvironmentApplyer)
      end
    end

    context 'when apply_type is :environment' do
      let(:args) { { scope: :environment } }

      it 'return AwsSsmEnv::EnvironmentApplyer' do
        expect(applyer).to be_a(AwsSsmEnv::EnvironmentApplyer)
      end
    end

    context 'when apply_type is :settings' do
      let(:args) { { scope: :settings } }

      it 'return AwsSsmEnv::SettingsApplyer' do
        expect(applyer).to be_a(AwsSsmEnv::SettingsApplyer)
      end
    end

    context 'when applyer is OpenStruct instance' do
      let(:applyer_instance) { OpenStruct.new }
      let(:args) { { scope: applyer_instance } }

      it 'return it as is' do
        expect(applyer).to eq(applyer_instance)
      end
    end

    context 'in other cases' do
      it 'raise error' do
        expect { described_class.create_applyer(scope: 'foo') }.to raise_error(ArgumentError)
      end
    end
  end
end
