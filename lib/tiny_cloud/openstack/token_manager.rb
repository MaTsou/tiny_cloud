module TinyCloud
  module Openstack
    class TokenManager
      include TinyCloud::TimeCalculation

      attr_reader :account, :configuration, :auth_token_birth, :auth_token
      attr_accessor :warms_up

      def initialize( account )
        @account = account
        @configuration = account.configuration
        @warms_up = [ TinyCloud::WarmUp.new( :auth_token_expired, self ) ]
        @auth_token_birth = now -
          2 * convert_in_seconds( @configuration.auth_token_reset_after )
      end

      # ----------------------------------------
      # auth_token_expired warm up
      # ----------------------------------------
      def auth_token_expired?( *args, **options )
        now > auth_token_birth +
          convert_in_seconds( configuration.auth_token_reset_after )
      end

      def auth_token_expired_request( *args, **options )
        {
          url: token_url,
          method: :post,
          options: { headers: renewing_headers, body: renewing_body }
        }
      end

      def auth_token_expired_handling( response )
        # TODO manage response issues..
        case response
        in status2xx: response
          @auth_token = response.headers['x-subject-token']
          @auth_token_birth = now
        else end
      end

      private

      def token_url
        [ configuration.auth_url, 'auth', 'tokens' ].join '/'
      end

      def renewing_headers
        { 'Content-Type' => 'application/json' }
      end

      def renewing_body
        {
          auth: {
            identity: {
              methods: ["password"],
              password: {
                user: {
                  domain: { name: configuration.user_domain_name },
                  name: configuration.user_name,
                  password: configuration.password
                }
              }
            },
            scope: {
              project: {
                domain: { name: configuration.project_domain_name },
                name: configuration.project_name
              }
            }
          }
        }.to_json
      end

    end
  end
end
