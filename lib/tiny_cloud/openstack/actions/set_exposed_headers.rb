# frozen_string_literal: true

module TinyCloud
  module Openstack
    module Actions
      # set exposed header action definition
      class SetExposedHeaders
        include TinyCloud::Chainable

        def supported?
          context.type == :container
        end

        def request
          request_processor.call(
            {
              url: context[:url],
              path: context[:path],
              method: :post,
              options: {
                headers: auth_manager.headers.merge(exposed_header)
              }
            }.compact
          )
        end

        private

        def exposed_header
          { 'X-Container-Meta-Access-Control-Expose-Headers' =>
            context.exposed_headers }
        end
      end
    end
  end
end
