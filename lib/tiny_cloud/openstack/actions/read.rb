module TinyCloud
  module Openstack
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
