# frozen_string_literal: true

module TinyCloud
  module Openstack
    module Hooks
      # openstack temp url key missing hook defintion
      class TempUrlKeyMissing
        include TinyCloud::Chainable

        HEADER_NAMES = %w[
          X-Container-Meta-Temp-URL-Key
          X-Container-Meta-Temp-URL-Key-2
        ].freeze

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

        def handle(response)
          case response
          in status2xx: response
            temp_url_manager.build_keys extract_keys_from(response)
          else end
        end

        private

        def extract_keys_from(response)
          HEADER_NAMES.to_h do |header|
            [header, response.headers.fetch(header.downcase, nil)]
          end
        end
      end
    end
  end
end
