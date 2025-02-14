module TinyCloud
  module Openstack
    module Actions
      class SetExposedHeaders
        include TinyCloud::Chainable

        def supported?
          context.type == :container
        end

        def request
          request_processor.call(
            {
              options: { headers: auth_manager.headers.merge( exposed_header ) },
              url: context[:url],
              path: context[:path],
              method: :post
            }.compact
          )
        end

        private

        def exposed_header
          { 'X-Container-Meta-Access-Control-Exposed-Headers' =>
            context.exposed_headers }
        end
      end
    end
  end
end
