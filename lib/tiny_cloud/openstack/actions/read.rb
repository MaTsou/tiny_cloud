module TinyCloud
  module Openstack
    class Read
      include TinyCloud::Chainable

      def request
        request_processor.call(
          { options: { headers: header },
            url: context[:url],
            path: context[:path],
            method: :get
          }.compact
        )
      end
    end
  end
end
