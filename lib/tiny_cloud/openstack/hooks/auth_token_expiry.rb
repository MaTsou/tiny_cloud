# frozen_string_literal: true

module TinyCloud
  module Openstack
    module Hooks
      # auth token expiry hook definition
      class AuthTokenExpiry
        include TinyCloud::Chainable
        attr_reader :config

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

        def handle(response)
          case response
          in status2xx: response
            auth_manager.set_token(
              response.headers['x-subject-token'], expiry(response)
            )
          in status4xx: response
            # TODO: to be sent to logger..
            p "Auth Token setting unauthorize error : #{response}"
          else end
        end

        private

        def expiry(response)
          Time
            .new(JSON.parse(response.body)['token']['expires_at'])
            .getlocal
        end

        def renewing_headers
          { 'Content-Type' => 'application/json' }
        end

        def renewing_body
          @config = configuration
          {
            auth: { identity: identity, scope: scope }
          }.to_json
        end

        def identity
          {
            methods: ['password'],
            password: {
              user: {
                domain: { name: config.user_domain_name },
                name: config.user_name,
                password: config.password
              }
            }
          }
        end

        def scope
          {
            project: {
              domain: { name: config.project_domain_name },
              name: config.project_name
            }
          }
        end
      end
    end
  end
end
