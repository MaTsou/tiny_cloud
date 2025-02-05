module TinyCloud
  module Openstack
    class AuthTokenExpiry
      include TinyCloud::Chainable

      def needed?
        auth_manager.token_expired?
      end

      def request
        request_processor.call(
          {
            url: auth_manager.token_url,
            method: :post,
            options: { headers: renewing_headers, body: renewing_body }
          }
        )
      end

      def handle( response )
        case response
        in status2xx: response
          auth_manager.set_token(
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

      def renewing_headers
        { 'Content-Type' => 'application/json' }
      end

      def renewing_body
        config = configuration
        {
          auth: {
            identity: {
              methods: ["password"],
              password: {
                user: {
                  domain: { name: config.user_domain_name },
                  name: config.user_name,
                  password: config.password
                }
              }
            },
            scope: {
              project: {
                domain: { name: config.project_domain_name },
                name: config.project_name
              }
            }
          }
        }.to_json
      end

    end
  end
end
