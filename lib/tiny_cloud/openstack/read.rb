module TinyCloud
  module Openstack
    class Read < TinyCloud::Hook
      include ActionHook, Hooks

      def before_hooks
        chain( Hooks[:auth_token_expired] )
      end

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
