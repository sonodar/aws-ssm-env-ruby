require 'spec_helper'

describe AwsSsmEnv::Loader do
  let(:client) do
    client = Aws::SSM::Client.new(stub_responses: true)
    client.stub_responses(
      :get_parameters_by_path,
      parameters: [
        { name: '/path/to/HOGE', value: 'hoge', type: 'SecureString', version: 1 },
        { name: '/path/to/HOGE/HAGE', value: 'hage', type: 'String', version: 2 },
      ],
      next_token: nil
    )
    client
  end

  describe '#call' do
    it 'EC2 Parameter Storeの値が環境変数に設定されていること' do
      described_class.call(client: client, path: '/path')
      expect(ENV['HOGE']).to eq('hoge')
    end

    it 'すでに環境変数が存在する場合は上書きしないこと' do
      ENV['HAGE'] = 'はげ'
      described_class.call(client: client, path: '/path')
      expect(ENV['HAGE']).to eq('はげ')
    end
  end

  describe '#call!' do
    it 'EC2 Parameter Storeの値が環境変数に上書きで設定されていること' do
      ENV['HAGE'] = 'はげ'
      described_class.call!(client: client, path: '/path')
      expect(ENV['HOGE']).to eq('hoge')
      expect(ENV['HAGE']).to eq('hage')
    end
  end

  describe '#new' do
    it 'fetcherが指定された場合はParameter Storeの値取得にそれを利用すること' do
      described_class.call!(fetcher: AwsSsmEnv::PathFetcher.new(client: client, path: '/path'))
      expect(ENV['HOGE']).to eq('hoge')
      expect(ENV['HAGE']).to eq('hage')
    end

    it 'namingが指定された場合は環境変数名の決定にそれを利用すること' do
      naming_strategy = Class.new do
        def parse_name(parameter)
          parameter.name.sub(%r{\A\/}, '').tr('/', '_').upcase
        end
      end.new
      described_class.call!(client: client, path: '/path', naming: naming_strategy)
      expect(ENV['PATH_TO_HOGE']).to eq('hoge')
      expect(ENV['PATH_TO_HOGE_HAGE']).to eq('hage')
    end
  end
end
