module TinyCloud
  module Openstack
    class TempUrlKeyMissing
      include TinyCloud::Chainable

      HEADER_NAMES = {
        first: "X-Container-Meta-Temp-URL-Key",
        second: "X-Container-Meta-Temp-URL-Key-2",
      }

      Key = Struct.new( :id, :header, :value, :birth_date )

      def needed?
        temp_url_manager.keys_missing?
      end

      def request
        request_processor.call(
          {
            url: context.url,
            method: :get,
            options: { headers: auth_manager.headers }
          }
        )
      end

      def handle( response )
        case response
        in status2xx: response
          temp_url_manager.set_keys( extract_keys_from response )
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
              birth_date: Time.now
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
