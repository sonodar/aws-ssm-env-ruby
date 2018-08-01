require 'spec_helper'

describe AwsSsmEnv::ParameterSetter do
  let(:parameter_setter) { described_class.new(args) }
  let(:args) { {} }

  describe '#initialize' do
    context 'when scope was not set' do
      let(:args) { { scope: nil } }

      it 'scope should default to ENV' do
        expect(parameter_setter.scope).to eq(ENV)
      end
    end

    context 'when scope is OpenStruct instance' do
      let(:parameter_scope) { OpenStruct.new }
      let(:args) { { scope: parameter_scope } }

      it 'return it as is' do
        expect(parameter_setter.scope).to eq(parameter_scope)
      end
    end

    context 'in other cases' do
      let(:args) { { scope: 'foo' } }

      it 'raise error' do
        expect { parameter_setter }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#save' do
    context 'when overwrite is false' do
      it 'does not existing parameters' do
        ENV['foo'] = nil
        ENV['fizz'] = 'fizz'

        parameter_setter.save('foo', 'bar')
        parameter_setter.save('fizz', 'buzz')

        expect(ENV['foo']).to eq('bar')
        expect(ENV['fizz']).to eq('fizz')
      end
    end

    context 'when overwrite is true' do
      let(:args) { { overwrite: 'TrUe' } }

      it 'overwrites existing parameters' do
        ENV['foo'] = nil
        ENV['fizz'] = 'fizz'

        parameter_setter.save('foo', 'bar')
        parameter_setter.save('fizz', 'buzz')

        expect(ENV['foo']).to eq('bar')
        expect(ENV['fizz']).to eq('buzz')
      end
    end
  end
end
