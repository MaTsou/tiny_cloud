module TinyCloud
  module Openstack
    class TokenManager
      include TinyCloud::TimeCalculation
      AUTH_TOKEN_OVERLAP = { hours: 1 }

      attr_reader :auth_token_expires_at, :auth_token

      def initialize
        @auth_token_expires_at = Time.new( 1900 ) # expired !
      end

      def token_expired?
        now > auth_token_reset_time
      end

      def set_auth_token( token, time )
        @auth_token = token
        @auth_token_expires_at = time
      end

      def auth_token_reset_time
        auth_token_expires_at - convert_in_seconds( AUTH_TOKEN_OVERLAP )
      end
    end
  end
end
