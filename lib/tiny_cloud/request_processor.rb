module TinyCloud
  class RequestProcessor
    attr_accessor :http_client, :request_formatter

    def initialize( http_client: nil )
      @http_client = http_client || TinyCloud::Excon::HttpClient.new
      @request_formatter = TinyCloud::Request.new
      yield self if block_given?
    end

    def call( request )
      http_client.call( request_formatter.call request )
    end

  end
end
