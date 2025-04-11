# frozen_string_literal: true

module TinyCloud
  module Openstack
    module Actions
      # list action definition
      class List
        include TinyCloud::Chainable

        def request
          request_processor.call(
            {
              url: context[:url],
              path: context[:path],
              method: :get,
              options: { headers: auth_manager.headers }
            }.compact
          )
        end
      end
    end
  end
end
