require 'spec_helper'
require 'logger'

describe AwsSsmEnv do
  let(:ssm_client) {
    stub_responses = {
      get_parameters_by_path: {
        parameters: [
          { name: 'foo', value: 'bar', type: 'String', version: 1 },
          { name: 'fizz', value: 'buzz', type: 'String', version: 1 }
        ],
        next_token: nil
      }
    }
    Aws::SSM::Client.new(stub_responses: stub_responses)
  }
  let(:logger) { Logger.new('/dev/null') }

  describe '#load' do
    context 'when overwrite is false' do
      it 'environment variables were not overwritten' do
        ENV['foo'] = nil
        ENV['fizz'] = 'fizz'

        described_class.load(client: ssm_client, path: '/path')

        expect(ENV['foo']).to eq('bar')
        expect(ENV['fizz']).to eq('fizz')
      end
    end

    context 'when overwrite is true' do
      it 'environment variables were overwritten' do
        ENV['foo'] = nil
        ENV['fizz'] = 'fizz'

        described_class.load!(client: ssm_client, path: '/path', logger: logger)

        expect(ENV['foo']).to eq('bar')
        expect(ENV['fizz']).to eq('buzz')
      end
    end
  end

  # @example Request syntax with placeholder values
  #
  #   resp = client.put_parameter({
  #     name: "PSParameterName", # required
  #     description: "ParameterDescription",
  #     value: "PSParameterValue", # required
  #     type: "String", # required, accepts String, StringList, SecureString
  #     key_id: "ParameterKeyId",
  #     overwrite: false,
  #     allowed_pattern: "AllowedPattern",
  #   })
  #
  describe 'Integration test', integration: true do
    PARAMETERS = [
      { name: '/test/aws-ssm-env/db_password', value: 'db_password', type: :SecureString },
      { name: '/test/aws-ssm-env/db/username', value: 'db_username', type: :String },
      { name: '/test/aws-ssm-env/roles', value: 'admin,guest', type: :StringList },
      { name: 'test.aws-ssm-env.db_password', value: 'db_password', type: :SecureString },
      { name: 'test.aws-ssm-env.username', value: 'db_username', type: :String },
      { name: 'test.aws-ssm-env.roles', value: 'admin,guest', type: :StringList },
    ].freeze
    ENV_NAMES = %w(db_password username roles).freeze

    def remove_env_all
      ENV_NAMES.each do |name|
        ENV[name] = nil
        ENV[name.upcase] = nil
      end
    end

    before :all do
      @client = Aws::SSM::Client.new
      PARAMETERS.each do |parameter|
        @client.put_parameter(
          name: parameter[:name],
          value: parameter[:value],
          type: parameter[:type].to_s,
          overwrite: true
        )
      end
    end

    before :each do
      remove_env_all
    end

    after :all do
      @client.delete_parameters(names: PARAMETERS.map { |p| p[:name] })
    end

    after :each do
      remove_env_all
    end

    describe 'path fetcher' do
      context 'when recursive is true' do
        it 'set environment variables from EC2 Parameter Store parameters' do
          described_class.load(path: '/test/aws-ssm-env', recursive: true, logger: logger)
          expect(ENV['db_password']).to eq('db_password')
          expect(ENV['username']).to eq('db_username')
          expect(ENV['roles']).to eq('admin,guest')
        end
      end

      context 'when recursive is false' do
        it 'set environment variables from EC2 Parameter Store parameters' do
          described_class.load(path: '/test/aws-ssm-env', recursive: false, logger: logger)
          expect(ENV['db_password']).to eq('db_password')
          expect(ENV['username']).to be_nil
          expect(ENV['roles']).to eq('admin,guest')
        end
      end
    end

    describe 'begins_with fetcher' do
      it 'set environment variables from EC2 Parameter Store parameters' do
        described_class.load(begins_with: 'test.aws-ssm-env.', naming: :snakecase, delimiter: '.', logger: logger)
        expect(ENV['DB_PASSWORD']).to eq('db_password')
        expect(ENV['USERNAME']).to eq('db_username')
        expect(ENV['ROLES']).to eq('admin,guest')
      end
    end
  end
end
