module TinyCloud
  module Openstack
    class AuthTokenExpiry < TinyCloud::Hook

      def needed?
        token_manager.token_expired?
      end

      def request
        request_processor.call(
          {
            url: token_url,
            method: :post,
            options: { headers: renewing_headers, body: renewing_body }
          }
        )
      end

      def handle( response )
        case response
        in status2xx: response
          token_manager.set_auth_token(
            response.headers['x-subject-token'], expiry( response )
          )
        in status4xx: response
          # todo to be sent to logger..
          p "Auth Token setting unauthorize error : #{response}"
        else end
      end

      private

      def expiry( response )
        Time
          .new( JSON.parse(response.body)['token']['expires_at'] )
          .getlocal
      end

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
