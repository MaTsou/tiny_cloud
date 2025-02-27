module TinyCloud
  module Openstack
    module Hooks
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
              headers: auth_manager.headers.merge( set_temp_url_key_header )
            }
          )
        end

        def handle( response )
          case response
          in status2xx: response
            new_death_date = Time.now + temp_url_manager.reset_key_after / 2

            %i( other active ).each do |status|# order is important..
              key = temp_url_manager.keys[ status ]
              next unless key.nil_or_expired?

              new_death_date += temp_url_manager.reset_key_after / 2# shift keys
              # Here, because of POST request, headers do not contain 
              # TempUrlKeys..
              key.value = @new_keys[ key.header ]
              key.death_date = new_death_date
            end
          else end # FIXME server error managment needed..
          # TODO to be continued
          temp_url_manager.permute_keys
        end

        private

        def set_temp_url_key_header
          # set both because sometime both are expired..
          @new_keys = temp_url_manager.keys.map do |status, key|
            [ key.header, key.build_value( status ) ]
          end.to_h
        end

      end
    end
  end
end
