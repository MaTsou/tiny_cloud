# frozen_string_literal: true

module TinyCloud
  module Openstack
    module Actions
      # set allowed origins action definition
      class SetAllowedOrigins
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
              options: { headers: auth_manager.headers.merge(cors_header) }
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
