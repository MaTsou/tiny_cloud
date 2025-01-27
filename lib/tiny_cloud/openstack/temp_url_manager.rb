require 'json'
require_relative 'temp_url_builder'

module TinyCloud
  module Openstack
    class TempUrlManager
      include TinyCloud::TimeCalculation

      HEADER_NAMES = {
        # containers only then !
        # TODO check if this is container dependant or not. Because later case 
        # would lead to issues when multiple apps..
        first: "X-Container-Meta-Temp-URL-Key",
        second: "X-Container-Meta-Temp-URL-Key-2",
      }

      Key = Struct.new( :id, :header, :value, :birth_date )

      attr_reader :account, :keys, :hooks, :caller_url,
        :builder, :reset_key_after

      def initialize( account )
        @account = account
        @reset_key_after = account.configuration.temp_url_key_reset_after
        @builder = Openstack::TempUrlBuilder.new( account.configuration )
        @hooks = %i( tuk_missing tuk_expired ).map do |w|
          TinyCloud::Hook.new( w, self )
        end
      end

      def build_temp_url( caller_url:, url:, method:, life_time:, prefix: )
        builder.call( url:, method:, prefix:, life_time: )
      end

      # ----------------------------------------
      # start : tuk missing hook
      # ----------------------------------------
      def tuk_missing?( *args, **options )
        !keys
      end

      def tuk_missing_request( *args, **options )
        {
          url: options[:caller_url],
          method: :get
        }
      end

      def tuk_missing_handling( response )
        ids = { first: :active, second: :other }

        case response
        in status2xx: response
          @keys = HEADER_NAMES.map do |k, v|
            [ k,
              Key.new(
                id: k,
                header: v,
                value: response.headers.fetch( v.downcase, nil ),
                birth_date: now
              )
            ]
          end.to_h.transform_keys( ids )
        else end
        push_key_to_builder
      end
      # ----------------------------------------
      # end : tuk missing hook
      # ----------------------------------------

      # ----------------------------------------
      # start : tuk expired hook
      # ----------------------------------------
      def tuk_expired?( *args, **options )
        return false
        death_date( keys[:active] ) < tomorrow
      end

      def tuk_expired_request( *args, **options )
      end

      def tuk_expired_handling( response )
        case response
        in status2xx:
          JSON.parse response.body
        else end # FIXME server error managment needed..
        # TODO to be continued
        push_key_to_builder
      end
      # ----------------------------------------
      # end : tuk expired hook
      # ----------------------------------------

      private

      def push_key_to_builder
        builder.set_active_key keys[:active].value
      end

      def death_date( key )
        key.birth_date + convert_in_seconds( reset_key_after )
      end
    end
  end
end
