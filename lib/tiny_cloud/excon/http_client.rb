# frozen_string_literal: true

require 'excon'

module TinyCloud
  module Excon
    # This is the http client
    class HttpClient
      attr_reader :response_formatter

      def initialize(formatter = TinyCloud::Excon::ResponseFormatter.new)
        @response_formatter = formatter
      end

      def call(request)
        response_formatter.call(
          ::Excon
          .new(request.url)
          .send(request.http_method, **request.http_options)
        )
      end
    end
  end
end
