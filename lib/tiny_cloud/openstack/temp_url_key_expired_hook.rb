module TinyCloud
  module Openstack
    class TempUrlKeyExpiredHook < TinyCloud::Hook
      def needed?( *args, **options )
        return false # temporary
        death_date( keys[:active] ) < tomorrow
      end

      def request( *args, **options )
      end

      def handle( response )
        case response
        in status2xx: response
          JSON.parse response.body
        else end # FIXME server error managment needed..
        # TODO to be continued
        push_key_to_builder
      end
    end
  end
end
