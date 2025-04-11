# frozen_string_literal: true

module TinyCloud
  module Openstack
    # openstack auth manager
    class AuthManager
      include TinyCloud::TimeCalculation
      AUTH_TOKEN_OVERLAP = { hours: 1 }.freeze

      attr_reader :token_expires_at, :token, :config

      def initialize(config)
        @config = config
        @token_expires_at = Time.new(1900) # expired !
      end

      def token_expired?
        now > token_reset_time
      end

      def set_token(token, time)
        @token = token
        @token_expires_at = time
      end

      def token_reset_time
        token_expires_at - convert_in_seconds(AUTH_TOKEN_OVERLAP)
      end

      def token_url
        [config.auth_url, 'auth', 'tokens'].join('/')
      end

      def headers
        { 'X-Auth-Token' => token }
      end
    end
  end
end
