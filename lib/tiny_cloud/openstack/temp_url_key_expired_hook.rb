module TinyCloud
  module Openstack
    class TempUrlKeyExpiredHook < TinyCloud::Hook
      def needed?
        return false # temporary
        temp_url_manager.keys_expired?
      end

      def request
      end

      def handle( response )
        case response
        in status2xx: response
          JSON.parse response.body
        else end # FIXME server error managment needed..
        # TODO to be continued
        temp_url_manager.update_keys#push_key_to_builder
      end
    end
  end
end
