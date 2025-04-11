# frozen_string_literal: true

module TinyCloud
  module Excon
    # this is http response formatter
    class ResponseFormatter
      def call(response)
        { status_type(response.status).to_sym => response }
      end

      private

      def status_type(status)
        "status#{status.to_i / 100}xx"
      end
    end
  end
end
