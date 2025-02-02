module TinyCloud
  class RequestProcessor
    attr_accessor :http_client, :request_formatter

    def initialize( http_client: TinyCloud::Excon::HttpClient.new )
      @http_client = http_client
      @request_formatter = TinyCloud::Request.new
    end

    def call( request )
      http_client.call( request_formatter.call request )
    end

  end
end
