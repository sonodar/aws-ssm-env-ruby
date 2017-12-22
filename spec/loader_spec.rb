require "spec_helper"

describe AwsSsmEnv::Loader do

  before :each do
    @client = Aws::SSM::Client.new(stub_responses: true)
    @client.stub_responses(:get_parameters_by_path,
     parameters: [
                     { name: '/path/to/HOGE', value: 'hoge', type: 'SecureString', version: 1 },
                     { name: '/path/to/HOGE/HAGE', value: 'hage', type: 'String', version: 2},
             ], next_token: nil)
  end

  describe '#call' do
    it 'EC2 Parameter Storeの値が環境変数に設定されていること' do
      AwsSsmEnv::Loader.call(client: @client, path: '/path')
      expect(ENV['HOGE']).to eq("hoge")
    end

    it 'すでに環境変数が存在する場合は上書きしないこと' do
      ENV['HAGE'] = 'はげ'
      AwsSsmEnv::Loader.call(client: @client, path: '/path')
      expect(ENV['HAGE']).to eq('はげ')
    end
  end

  describe '#call!' do
    it 'EC2 Parameter Storeの値が環境変数に上書きで設定されていること' do
      ENV['HAGE'] = 'はげ'
      AwsSsmEnv::Loader.call!(client: @client, path: '/path')
      expect(ENV['HOGE']).to eq("hoge")
      expect(ENV['HAGE']).to eq("hage")
    end
  end

  describe '#new' do
    it 'fetcherが指定された場合はParameter Storeの値取得にそれを利用すること' do
      AwsSsmEnv::Loader.call!(fetcher: AwsSsmEnv::PathFetcher.new(client: @client, path: '/path'))
      expect(ENV['HOGE']).to eq("hoge")
      expect(ENV['HAGE']).to eq("hage")
    end

    it 'namingが指定された場合は環境変数名の決定にそれを利用すること' do
      naming_strategy = Class.new {
        def parse_name(parameter)
          parameter.name.gsub(/\//, '_').upcase
        end
      }.new
      AwsSsmEnv::Loader.call!(client: @client, path: '/path', naming: naming_strategy)
      expect(ENV['_PATH_TO_HOGE']).to eq("hoge")
      expect(ENV['_PATH_TO_HOGE_HAGE']).to eq("hage")
    end
  end

end
