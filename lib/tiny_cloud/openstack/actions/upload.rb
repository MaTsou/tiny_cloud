module TinyCloud
  module Openstack
    module Actions
      class Upload
        include TinyCloud::Chainable

        def request
          # FIXME do not work..
          request_processor.call(
            {
              options: {
                headers: auth_manager.headers.merge( context[:headers] || {} ),
                body: context[:body]
              },
              url: context[:url],
              path: context[:path],
              method: :put
            }.compact
          )
        end
      end
    end
  end
end
