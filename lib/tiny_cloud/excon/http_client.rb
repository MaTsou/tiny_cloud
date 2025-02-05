require 'excon'

module TinyCloud
  module Excon
    class HttpClient
      attr_reader :response_formatter

      def initialize( formatter = TinyCloud::Excon::ResponseFormatter.new )
        @response_formatter = formatter
      end

      def call( request )
        response_formatter.call(
          ::Excon
          .new( request.url )
          .send( request.method, **request.options )
        )
      end
    end
  end
end
