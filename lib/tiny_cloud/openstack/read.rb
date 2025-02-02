module TinyCloud
  module Openstack
    class Read < Openstack::Action

      def before_hooks
        [ registered_hooks[:auth_token_expiry] ]
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
