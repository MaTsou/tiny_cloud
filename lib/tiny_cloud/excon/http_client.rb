require 'excon'
require_relative 'response_formatter'

module TinyCloud
  module Excon
    class HttpClient
      attr_reader :response_formatter

      def initialize( response_formatter = TinyCloud::Excon::ResponseFormatter )
        @response_formatter = response_formatter
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
