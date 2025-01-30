module TinyCloud
  module Openstack
    class TempUrlKeyMissingHook < TinyCloud::Hook
      # Maybe a TukHook super class cloud be needed to store all common stuff.

      HEADER_NAMES = {
        first: "X-Container-Meta-Temp-URL-Key",
        second: "X-Container-Meta-Temp-URL-Key-2",
      }

      Key = Struct.new( :id, :header, :value, :birth_date )

      def needed?( *args, **options )
        !keys
      end

      def request( **options )
          {
            url: options[:url],
            method: :get,
            options: { headers: holder.account.header }
          }
      end

      def handle( response )
        case response
        in status2xx: response
          set_keys( extract_keys_from response )
          push_key_to_builder
        else end
      end

      private

      def extract_keys_from( response )
        HEADER_NAMES.map do |k, v|
          [ k,
            Key.new(
              id: k,
              header: v,
              value: response.headers.fetch( v.downcase, nil ),
              birth_date: now
            )
          ]
        end.to_h.transform_keys( ids )
      end

      def ids
        { first: :active, second: :other }
      end
    end
  end
end
