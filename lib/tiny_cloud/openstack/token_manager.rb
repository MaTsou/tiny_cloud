module TinyCloud
  module Openstack
    module TokenManager
      include TinyCloud::TimeCalculation

      private

      def reset_auth_token_request
        {
          url: token_url,
          method: :post,
          options: { headers: renewing_headers, body: renewing_body }
        }
      end

      def token_still_valid?
        now < auth_token_birth +
          convert_in_seconds( configuration.auth_token_reset_after )
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
