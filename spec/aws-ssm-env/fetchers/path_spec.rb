require 'spec_helper'
require 'aws-ssm-env/fetchers/path'

describe AwsSsmEnv::PathFetcher do
  let(:fetcher) { described_class.new(**args) }
  let(:args) { { path: '/path' } }
  let(:base_params) { fetcher.instance_variable_get(:'@base_params') }

  describe '#initialize' do
    context 'when path was not set' do
      it 'raise error' do
        expect { described_class.new(path: nil) }.to raise_error(ArgumentError)
      end
    end

    context 'when :path was set' do
      it '@base_params[:path] is argument value' do
        expect(base_params[:path]).to eq('/path')
      end
    end

    context 'when recursive was not set' do
      it '@base_params[:recursive] is false' do
        expect(base_params[:recursive]).to be_falsey
      end
    end

    context 'when recursive is truthy string' do
      let(:args) { { path: '/path', recursive: 'TruE' } }

      it '@base_params[:recursive] is true' do
        expect(base_params[:recursive]).to be_truthy
      end
    end

    context 'when recursive is not truthy string' do
      let(:args) { { path: '/path', recursive: 'foo' } }

      it '@base_params[:recursive] is false' do
        expect(base_params[:recursive]).to be_falsey
      end
    end

    context 'when :fetch_size was set and less than 10' do
      let(:args) { { path: '/path', fetch_size: 5 } }

      it '@base_params[:max_results] is fetch_size value' do
        expect(base_params[:max_results]).to eq(5)
      end
    end

    context 'when :fetch_size was not set' do
      it '@base_params[:max_results] is 10' do
        expect(base_params[:max_results]).to eq(10)
      end
    end

    context 'when :fetch_size is nil' do
      let(:args) { { path: '/path', fetch_size: nil } }

      it '@base_params[:max_results] is 10' do
        expect(base_params[:max_results]).to eq(10)
      end
    end

    context 'when :fetch_size > 10' do
      let(:args) { { path: '/path', fetch_size: 11 } }

      it '@base_params[:max_results] is 10' do
        expect(base_params[:max_results]).to eq(10)
      end
    end
  end

  describe '#fetch' do
    before do
      allow_any_instance_of(Aws::SSM::Client).to \
        receive(:get_parameters_by_path).and_return(nil)
    end

    let(:client) { fetcher.send(:client) }

    context 'when next_token is nil' do
      it 'called get_parameters_by_path without next_token' do
        expect(fetcher.send(:fetch, nil)).to be_nil
        expect(client).to \
          have_received(:get_parameters_by_path).with(base_params).once
      end
    end

    context 'when next_token is not nil' do
      it 'called get_parameters_by_path with next_token' do
        expect(fetcher.send(:fetch, 'next_token')).to be_nil
        expect(client).to \
          have_received(:get_parameters_by_path)
          .with(base_params.merge(next_token: 'next_token')).once
      end
    end
  end
end
