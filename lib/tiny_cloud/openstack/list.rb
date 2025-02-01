module TinyCloud
  module Openstack
    class List < TinyCloud::Hook
      def request( **context )
        { options: { headers: header } }.merge(
          { url: context[:url], path: context[:path], method: :get }.compact
        )
      end
    end
  end
end
