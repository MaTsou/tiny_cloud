module TinyCloud
  module Openstack
    module Actions
      class SetAllowedOrigins
        include TinyCloud::Chainable

        def supported?
          context.type == :container
        end

        def request
          request_processor.call(
            {
              options: { headers: auth_manager.headers.merge( cors_header ) },
              url: context[:url],
              path: context[:path],
              method: :post
            }.compact
          )
        end

        private

        def cors_header
          { 'X-Container-Meta-Access-Control-Allow-Origin' => context.origins }
        end
      end
    end
  end
end
