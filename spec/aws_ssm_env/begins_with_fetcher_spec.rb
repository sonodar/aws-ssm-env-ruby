require 'spec_helper'
require 'aws-ssm-env/fetchers/begins_with'

describe AwsSsmEnv::BeginsWithFetcher do
  let(:fetcher) { described_class.new(**args) }
  let(:args) { { begins_with: ['/foo', '/bar'] } }
  let(:base_params) { fetcher.instance_variable_get(:@base_params) }
  let(:parameter_filter) { base_params[:parameter_filters][0] }

  describe '#initialize' do
    context 'when :begins_with was not set' do
      it 'raise error' do
        expect { described_class.new(begins_with: nil) }.to raise_error(ArgumentError)
      end
    end

    context 'when :begins_with is Array' do
      it 'parameter_filter[:values] is begins_with value' do
        expect(parameter_filter[:values]).to eq(args[:begins_with])
      end
    end

    context 'when :begins_with is not Array' do
      let(:args) { { begins_with: '/foo' } }

      it 'parameter_filter[:values] is [ begins_with value ]' do
        expect(parameter_filter[:values]).to eq([args[:begins_with]])
      end
    end

    context 'when :fetch_size was set and less than 50' do
      let(:args) { { begins_with: '/foo', fetch_size: 49 } }

      it '@base_params[:max_results] is fetch_size value' do
        expect(base_params[:max_results]).to eq(49)
      end
    end

    context 'when :fetch_size was not set' do
      let(:args) { { begins_with: '/foo', fetch_size: nil } }

      it '@base_params[:max_results] is 50' do
        expect(base_params[:max_results]).to eq(50)
      end
    end

    context 'when :fetch_size > 50' do
      let(:args) { { begins_with: '/foo', fetch_size: 51 } }

      it '@base_params[:max_results] is 50' do
        expect(base_params[:max_results]).to eq(50)
      end
    end
  end

  describe '#fetch' do
    let(:client) { fetcher.send(:client) }

    context 'when describe_parameters return empty parameters' do
      before do
        allow_any_instance_of(Aws::SSM::Client).to \
          receive(:describe_parameters).and_return(AwsSsmEnv::FetchResult::EMPTY)
      end

      it 'return AwsSsmEnv::FetchResult::EMPTY' do
        expect(fetcher.send(:fetch, nil)).to eq(AwsSsmEnv::FetchResult::EMPTY)
      end

      context 'when next_token is nil' do
        it 'called describe_parameters without next_token' do
          expect(fetcher.send(:fetch, nil)).to eq(AwsSsmEnv::FetchResult::EMPTY)
          expect(client).to \
            have_received(:describe_parameters).with(base_params).once
        end
      end

      context 'when next_token is not nil' do
        it 'called get_parameters_by_path with next_token' do
          expect(fetcher.send(:fetch, 'next_token')).to eq(AwsSsmEnv::FetchResult::EMPTY)
          expect(client).to have_received(:describe_parameters)
            .with(base_params.merge(next_token: 'next_token')).once
        end
      end
    end

    context 'when describe_parameters return not empty parameters' do
      let!(:dummy_parameters) { [Parameter.new('foo'), Parameter.new('bar')] }
      let!(:dummy_response) { AwsSsmEnv::FetchResult.new(dummy_parameters, 'next_token') }

      before do
        allow_any_instance_of(Aws::SSM::Client).to \
          receive(:describe_parameters).and_return(dummy_response)
        allow_any_instance_of(Aws::SSM::Client).to \
          receive(:get_parameters).and_return(dummy_response)
      end

      it 'return parameters' do
        response = fetcher.send(:fetch, 'next_token')
        expect(response.parameters).to eq(dummy_response.parameters)
        expect(response.next_token).to eq(dummy_response.next_token)
        expect(client).to have_received(:get_parameters)
          .with(names: dummy_parameters.map(&:name), with_decryption: true).once
      end
    end
  end
end
