module TinyCloud
  module Openstack
    module TokenManager
      AUTH_TOKEN_LIFE_TIME = { days: 30 }

      private

      def reset_auth_token_request
        {
          url: token_url,
          method: :post,
          options: { headers: renewing_headers, body: renewing_body }
        }
      end

      def auth_token_life_period
        (0..1).map do |t|
          auth_token_birth + t * convert_in_seconds(AUTH_TOKEN_LIFE_TIME)
        end
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