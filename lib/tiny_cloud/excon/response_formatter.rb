module TinyCloud
  module Excon
    class ResponseFormatter
      def call( response )
        { status_type( response.status ) => response }
      end

      private

      def status_type( status )
        "status#{status.to_i / 100}xx".to_sym
      end
    end
  end
end
