module TinyCloud
  module Openstack
    class List < TinyCloud::Hook

      def request
        request_processor.call(
          {
            options: { headers: header },
            url: context[:url],
            path: context[:path],
            method: :get
          }.compact
        )
      end
    end
  end
end
