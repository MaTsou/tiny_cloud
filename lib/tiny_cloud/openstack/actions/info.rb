# frozen_string_literal: true

module TinyCloud
  module Openstack
    module Actions
      # info action definition
      class Info
        include TinyCloud::Chainable

        def request
          request_processor.call(
            {
              url: context[:url].origin,
              path: 'info',
              method: :get,
              options: { headers: auth_manager.headers }
            }.compact
          )
        end
      end
    end
  end
end
