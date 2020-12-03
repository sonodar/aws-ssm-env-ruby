require 'spec_helper'

describe AwsSsmEnv::FetcherFactory do
  describe '#create_fetcher' do
    let(:fetcher) { described_class.create_fetcher(**args) }

    context 'when fetch was not set' do
      context 'when begins_with was not set' do
        let(:args) { { path: '/path' } }

        it 'return AwsSsmEnv::PathFetcher' do
          expect(fetcher).to be_a(AwsSsmEnv::PathFetcher)
        end
      end

      context 'when begins_with was set' do
        let(:args) { { begins_with: '/path' } }

        it 'return AwsSsmEnv::BeginsWithFetcher' do
          expect(fetcher).to be_a(AwsSsmEnv::BeginsWithFetcher)
        end
      end
    end

    context 'when fetch is :path' do
      let(:args) { { fetch: :path, path: '/path' } }

      it 'return AwsSsmEnv::PathFetcher' do
        expect(fetcher).to be_a(AwsSsmEnv::PathFetcher)
      end
    end

    context 'when fetch is :begins_with' do
      let(:args) { { fetch: :begins_with, begins_with: '/path' } }

      it 'return AwsSsmEnv::BeginsWithFetcher' do
        expect(fetcher).to be_a(AwsSsmEnv::BeginsWithFetcher)
      end
    end

    context 'when fetch is AwsSsmEnv::Fetcher implementation instance' do
      let(:fetcher_class) { Class.new(AwsSsmEnv::Fetcher) { def fetch(_); end } }
      let(:fetcher_instance) { fetcher_class.new }
      let(:args) { { fetch: fetcher_instance } }

      it 'return it as is' do
        expect(fetcher).to eq(fetcher_instance)
      end
    end

    context 'when fetch has each method' do
      let(:args) { { fetch: [] } }

      it 'return it as is' do
        expect(fetcher).to eq([])
      end
    end

    context 'in other cases' do
      it 'raise error' do
        expect { described_class.create_fetcher(fetch: 'foo') }.to raise_error(ArgumentError)
      end
    end
  end
end
