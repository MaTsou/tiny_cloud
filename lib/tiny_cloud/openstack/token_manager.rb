require_relative 'auth_token_expired_hook'

module TinyCloud
  module Openstack
    class TokenManager
      include TinyCloud::TimeCalculation
      AUTH_TOKEN_OVERLAP = { hours: 1 }

      attr_reader :account, :configuration, :hooks,
        :auth_token_expires_at, :auth_token

      def initialize( account )
        @account = account
        @configuration = account.configuration
        @hooks = [
          TinyCloud::Openstack::AuthTokenExpiredHook.new(
            self, account.request_processor
          )
        ]
        @auth_token_expires_at = Time.new( 1900 ) # expired !
      end

      def set_auth_token( token, time )
        @auth_token = token
        @auth_token_expires_at = time
      end

      def hooks_for( action )
        hooks.dup
      end

      def auth_token_reset_time
        auth_token_expires_at - convert_in_seconds( AUTH_TOKEN_OVERLAP )
      end
    end
  end
end
