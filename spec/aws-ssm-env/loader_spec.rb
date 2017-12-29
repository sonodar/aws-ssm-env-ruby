require 'spec_helper'

describe AwsSsmEnv::Loader do
  let(:args) { { path: '/foo' } }

  describe '#initialize' do
    let(:loader) { described_class.new(args) }

    it 'has fetcher and naming_strategy' do
      expect(loader.instance_variable_get(:@fetcher)).to be_a(AwsSsmEnv::PathFetcher)
      expect(loader.instance_variable_get(:@naming_strategy)).to be_a(AwsSsmEnv::BasenameNamingStrategy)
    end

    describe 'overwrite option' do
      let(:applier) { loader.instance_variable_get(:@applier) }

      context 'when overwrite was not set' do
        it '@applier is not overwrite method' do
          expect(applier).to eq(:apply)
        end
      end

      context 'when overwrite is nil' do
        let(:args) { { path: '/foo', overwrite: nil } }

        it '@applier is not overwrite method' do
          expect(applier).to eq(:apply)
        end
      end

      context 'when overwrite is truthy string' do
        let(:args) { { path: '/foo', overwrite: 'truE' } }

        it '@applier is overwrite method' do
          expect(applier).to eq(:apply!)
        end
      end

      context 'when overwrite is not truthy string' do
        let(:args) { { path: '/foo', overwrite: 'foo' } }

        it '@applier is not overwrite method' do
          expect(applier).to eq(:apply)
        end
      end
    end
  end

  describe '#load' do
    context 'when overwrite is false' do
      it 'environment variables were not overwritten' do
        ENV['foo'] = nil
        ENV['fizz'] = 'fizz'

        loader = described_class.new(args)
        loader.instance_variable_set(:@fetcher,
          [ Parameter.new('foo', 'bar'), Parameter.new('fizz', 'buzz') ])

        loader.load

        expect(ENV['foo']).to eq('bar')
        expect(ENV['fizz']).to eq('fizz')
      end
    end

    context 'when overwrite is true' do
      let(:args) { { path: '/foo', overwrite: true } }

      it 'environment variables were overwritten' do
        ENV['foo'] = nil
        ENV['fizz'] = 'fizz'

        loader = described_class.new(args)
        loader.instance_variable_set(:@fetcher,
          [ Parameter.new('foo', 'bar'), Parameter.new('fizz', 'buzz') ])

        loader.load

        expect(ENV['foo']).to eq('bar')
        expect(ENV['fizz']).to eq('buzz')
      end
    end
  end
end
