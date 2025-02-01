module TinyCloud
  module Openstack
    class Read < TinyCloud::Hook
      def request( **context )
        { options: { headers: header } }.merge(
          { url: context[:url], path: context[:path], method: :get }.compact
        )
      end
    end
  end
end
