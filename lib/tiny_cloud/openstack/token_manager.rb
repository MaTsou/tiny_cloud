require_relative 'auth_token_expired_hook'

module TinyCloud
  module Openstack
    class TokenManager
      include TinyCloud::TimeCalculation

      attr_reader :account, :configuration, :hooks,
        :auth_token_birth, :auth_token

      def initialize( account )
        @account = account
        @configuration = account.configuration
        @hooks = [ TinyCloud::Openstack::AuthTokenExpiredHook.new( self ) ]
        @auth_token_birth = Time.new( 1900 ) # expired !
      end

      def set_auth_token( token, time )
        @auth_token = token
        @auth_token_birth = time
      end

    end
  end
end
