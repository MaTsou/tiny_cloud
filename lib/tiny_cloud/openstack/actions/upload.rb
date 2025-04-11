# frozen_string_literal: true

module TinyCloud
  module Openstack
    module Actions
      # upload action definition
      class Upload
        include TinyCloud::Chainable

        def request
          # FIXME: do not work..
          request_processor.call(
            {
              url: context[:url],
              path: context[:path],
              method: :put,
              options: options
            }.compact
          )
        end

        private

        def options
          {
            headers: auth_manager.headers.merge(context[:headers] || {}),
            body: context[:body]
          }
        end
      end
    end
  end
end
