module TinyCloud
  module Openstack
    class AuthTokenExpiredHook < TinyCloud::Hook
      include TinyCloud::TimeCalculation

      def needed?( **options )
        now > auth_token_birth +
          convert_in_seconds( configuration.auth_token_reset_after )
      end

      def request( **options )
          {
            url: token_url,
            method: :post,
            options: { headers: renewing_headers, body: renewing_body }
          }
      end

      def handle( response )
        case response
        in status2xx: response
          set_auth_token response.headers['x-subject-token'], now
        in status4xx: response
          # todo to be sent to logger..
          p "Auth Token setting unauthorize error : #{response}"
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
