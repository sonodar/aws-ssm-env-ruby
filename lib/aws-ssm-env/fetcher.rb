require 'aws-sdk-ssm'

module AwsSsmEnv

  class Fetcher

    attr_reader :fetch_size, :parameter_filters, :with_decryption, :next_token, :client

    def initialize(**args)
      @fetch_size = (args[:fetch_size] || 10).to_i
      @parameter_filters = args[:filters]
      @with_decryption = args[:decryption].nil? ? true : args[:decryption] === true
      @parameters = nil
      @current_index = nil
      @next_token = nil
      @client = args[:client] || Aws::SSM::Client.new(args[:ssm_client_args]||{})
    end

    def each
      fetch!
      until eos?
        fetch! if needs_fetch?
        yield(@parameters[@current_index])
        @current_index += 1
      end
    end

    protected

    def fetch; end

    def fetch!
      results = self.fetch
      @parameters = results.parameters
      @next_token = results.next_token
      @current_index = 0
    end

    private

    def eos?
      @next_token.nil? && @current_index >= @parameters.length
    end

    def needs_fetch?
      @current_index >= @parameters.length
    end

  end

  class PathFetcher < Fetcher

    def initialize(**args)
      super
      @path = args[:path]
      @recursive = args[:recursive].nil? ? false : args[:recursive] === true
    end

    protected

    def fetch
      client.get_parameters_by_path(
          path: @path,
          recursive: @recursive,
          parameter_filters: parameter_filters,
          with_decryption: with_decryption,
          max_results: fetch_size,
          next_token: next_token,
      )
    end

  end

end
