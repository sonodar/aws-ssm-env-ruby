require 'spec_helper'

describe AwsSsmEnv::Fetcher do
  let(:fetcher) { described_class.new(args) }
  let(:args) { {} }
  let(:client) { fetcher.send(:client) }
  let(:ssm_client_args) {
    {
      access_key_id: 'access_key_id',
      secret_access_key: 'secret_access_key'
    }
  }

  describe '#initialize' do
    context 'when decryption was not set' do
      it 'with_decryption is true' do
        expect(fetcher.send(:with_decryption)).to be_truthy
      end
    end

    context 'when decryption is nil' do
      let(:args) { { decryption: nil } }

      it 'with_decryption is true' do
        expect(fetcher.send(:with_decryption)).to be_truthy
      end
    end

    context 'when decryption is truthy string' do
      let(:args) { { decryption: 'TrUe' } }

      it 'with_decryption is true' do
        expect(fetcher.send(:with_decryption)).to be_truthy
      end
    end

    context 'when decryption is not truthy string' do
      let(:args) { { decryption: 'foo' } }

      it 'with_decryption is false' do
        expect(fetcher.send(:with_decryption)).to be_falsey
      end
    end

    context 'when client was not set' do
      context 'when ssm_client_args was set' do
        let(:args) { { ssm_client_args: ssm_client_args } }

        it 'client is initialized by ssm_client_args' do
          expect(client.config[:access_key_id]).to eq('access_key_id')
          expect(client.config[:secret_access_key]).to eq('secret_access_key')
        end
      end

      context 'when ssm_client_args was not set' do
        it 'client is default construction' do
          expect(client.config[:access_key_id]).to be_nil
        end
      end
    end

    context 'when client was set' do
      context 'when client is instance of Aws::SSM::Client' do
        let(:ssm_client) { Aws::SSM::Client.new }
        let(:args) { { client: ssm_client } }

        it 'client is equals to args[:client]' do
          expect(client).to eq(ssm_client)
        end
      end

      context 'when client is not instance of Aws::SSM::Client' do
        let(:ssm_client) { 'foo' }
        let(:args) { { client: ssm_client, ssm_client_args: ssm_client_args } }

        it 'client is not equals to args[:client] and client is initialized by ssm_client_args' do
          expect(client).not_to eq(ssm_client)
          expect(client.config[:access_key_id]).to eq('access_key_id')
          expect(client.config[:secret_access_key]).to eq('secret_access_key')
        end
      end
    end
  end

  describe '#each' do
    let(:parameters) { [ Parameter.new('foo', 'foo'), Parameter.new('bar', 'bar') ] }
    let(:fetcher) {
      mock_class = Class.new(described_class) do
        def initialize(response); @response = response; end
        protected def fetch(_); @response; end
      end
      mock_class.new(dummy_response)
    }

    context 'when fetch returns empty parameters at first' do
      let(:dummy_response) { AwsSsmEnv::FetchResult::EMPTY }

      it 'consumer is not called' do
        called = false
        fetcher.each do |_|
          called = true
        end
        expect(called).to be_falsey
      end
    end

    context 'when fetch returns two parameters at first and empty next_token' do
      let(:dummy_response) { AwsSsmEnv::FetchResult.new(parameters, nil) }

      it 'consumer is called twice' do
        called = 0
        fetcher.each do |_|
          called += 1
        end
        expect(called).to eq(2)
      end
    end

    context 'when fetch returns two parameters and next_token at first, fetch returns two parameters and empty next_token at second' do
      let(:fetcher) {
        mock_class = Class.new(described_class) do
          def initialize(parameters); @parameters = parameters; @count = 0; end
          protected def fetch(_)
            if @count == 0
              @count = 1
              AwsSsmEnv::FetchResult.new(@parameters, 'next_token')
            else
              AwsSsmEnv::FetchResult.new(@parameters, nil)
            end
          end
        end
        mock_class.new(parameters)
      }

      it 'consumer is called four times' do
        called = 0
        fetcher.each do |_|
          called += 1
        end
        expect(called).to eq(4)
      end
    end
  end

  describe '#fetch' do
    it 'raise error' do
      expect { fetcher.send(:fetch, 'next_token') }.to raise_error(NotImplementedError)
    end
  end
end

describe AwsSsmEnv::FetchResult do
  describe '#initialize' do
    subject { described_class.new([], 'next_token') }

    it { is_expected.to have_attributes(parameters: [], next_token: 'next_token') }
  end
end
