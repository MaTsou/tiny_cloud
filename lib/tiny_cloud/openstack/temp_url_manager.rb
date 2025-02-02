require 'json'

module TinyCloud
  module Openstack
    class TempUrlManager
      include TinyCloud::TimeCalculation

      attr_reader :keys, :reset_key_after

      def initialize( reset_key_after: { year: 1 } )
        @reset_key_after = reset_key_after
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
