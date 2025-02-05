module TinyCloud
  module Openstack
    module Actions
      class Read
        include TinyCloud::Chainable

        def request
          request_processor.call(
            {
              options: { headers: auth_manager.headers },
              url: context[:url],
              path: context[:path],
              method: :get
            }.compact
          )
        end
      end
    end
  end
end
