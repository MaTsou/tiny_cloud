module TinyCloud
  module Openstack
    module Hooks
      class TempUrlKeyMissing
        include TinyCloud::Chainable

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
          temp_url_manager.http_header_names.map do |header|
            [ header, response.headers.fetch( header.downcase, nil ) ]
          end.to_h
        end

      end
    end
  end
end
