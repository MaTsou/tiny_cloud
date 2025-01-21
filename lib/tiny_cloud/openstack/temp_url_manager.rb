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

      attr_reader :account, :configuration, :keys, :warms_up, :caller_url

      def initialize( account )
        @account = account
        @configuration = account.configuration
        @warms_up = %i( tuk_missing tuk_expired ).map do |w|
            TinyCloud::WarmUp.new( w, self )
          end
      end

      def build_temp_url( caller_url:, url:, method:, life_time:, prefix: )
        Openstack::TempUrlBuilder.new(
          root_url: configuration.root_url,
          url:, method:, prefix:,
          life_time: (life_time || configuration.temp_url_key_default_life_time),
          active_temp_url_key: keys[:active].value,
        ).call
      end

      # ----------------------------------------
      # tuk missing warm up
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
      end

      # ----------------------------------------
      # tuk expired warm up
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
      end

      private

      def death_date( key )
        key.birth_date +
          convert_in_seconds( configuration.temp_url_key_reset_after )
      end
    end
  end
end
