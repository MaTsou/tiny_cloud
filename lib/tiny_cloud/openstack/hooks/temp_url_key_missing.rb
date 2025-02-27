module TinyCloud
  module Openstack
    module Hooks
      class TempUrlKeyMissing
        include TinyCloud::Chainable

        HEADER_NAMES = [
          "X-Container-Meta-Temp-URL-Key",
          "X-Container-Meta-Temp-URL-Key-2",
        ]

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
          HEADER_NAMES.map do |header|
            [ header, response.headers.fetch( header.downcase, nil ) ]
          end.to_h
        end

      end
    end
  end
end
