require 'json'

module TinyCloud
  module Openstack
    class TempUrlManager
      include TinyCloud::TimeCalculation

      attr_reader :keys

      def initialize( config )
        @config = config
      end

      def reset_key_after
        @config.temp_url_key_reset_after
      end

      def default_life_time
        @config.temp_url_default_life_time
      end

      def keys_missing?
        !keys
      end

      def keys_expired?
        death_date( keys[:active] ) < tomorrow
      end

      def active_key
        keys[:active].value
      end

      def set_keys( keys )
        @keys = keys
      end

      private

      def death_date( key )
        key.birth_date + convert_in_seconds( reset_key_after )
      end
    end
  end
end
