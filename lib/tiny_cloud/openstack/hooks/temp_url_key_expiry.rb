# frozen_string_literal: true

module TinyCloud
  module Openstack
    module Hooks
      # openstack temp url key expirey hook definition
      class TempUrlKeyExpiry
        include TinyCloud::Chainable

        def needed?
          temp_url_manager.active_key.nil_or_expired?
        end

        def request
          request_processor.call(
            url: context.url,
            method: :post,
            options: {
              headers: auth_manager.headers.merge(set_temp_url_key_header)
            }
          )
        end

        def handle(response)
          case response
          in status2xx: response
            renew_temp_url_keys
          else end # FIXME: server error managment needed..
          # TODO: to be continued
          temp_url_manager.permute_keys
        end

        private

        def set_temp_url_key_header
          # set both because sometime both are expired..
          @new_keys = temp_url_manager.keys.to_h do |status, key|
            [key.header, key.build_value(status)]
          end
        end

        def renew_temp_url_keys
          new_death_date = Time.now + temp_url_key_half_life_time

          %i[other active].each do |status| # order is important..
            key = temp_url_manager.keys[status]
            next unless key.nil_or_expired?

            new_death_date += temp_url_key_half_life_time # shift keys
            update_key(key, new_death_date)
          end
        end

        def update_key(key, death_date)
          # Here, because of POST request, headers do not contain
          # TempUrlKeys..
          key.value = @new_keys[key.header]
          key.death_date = death_date
        end

        def temp_url_key_half_life_time
          temp_url_manager.reset_key_after / 2
        end
      end
    end
  end
end
