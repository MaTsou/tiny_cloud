# frozen_string_literal: true

module TinyCloud
  # request processor class
  class RequestProcessor
    attr_accessor :http_client, :request_formatter

    def initialize(
      http_client: TinyCloud::Excon::HttpClient.new,
      request_formatter: Struct.new(:url, :http_method, :http_options)
    )
      @http_client = http_client
      @request_formatter = request_formatter
    end

    def call(request)
      http_client.call formatted_request(request)
    end

    private

    def formatted_request(request)
      request_formatter.new(
        get_url(request),
        request[:http_method],
        request[:http_options]
      )
    end

    def get_url(request)
      join_paths request[:url], request[:path]
    end

    def join_paths(*paths)
      paths.compact.join('/')
    end
  end
end
