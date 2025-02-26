require 'json'

module TinyCloud
  module Openstack
    class TempUrlManager
      include TinyCloud::TimeCalculation

      HEADER_NAMES = {
        first: "X-Container-Meta-Temp-URL-Key",
        second: "X-Container-Meta-Temp-URL-Key-2",
      }

      Key = Struct.new( 'Key', :id, :header, :value, :death_date ) do
        include TinyCloud::TimeCalculation

        def expired?
          value.nil? || death_date < Time.now #tomorrow
        end

        def build_value
          expired? ? generate : value
        end

        private

        def generate
          "Unbreakable-#{Time.now}-Temp_Url_Key"
        end

      end

      attr_reader :keys

      def initialize( config )
        @config = config
      end

      def http_header_names
        self.class::HEADER_NAMES
      end

      def reset_key_after
        convert_in_seconds @config.temp_url_key_reset_after
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
        keys[:active]
      end

      def build_key( **options )
        options[:death_date] = options.delete( :birth_date ) + reset_key_after
        Key.new( **options )
      end

      def set_keys( keys )
        @keys = keys
        keys[:other].death_date += reset_key_after / 2
      end

      private

      def death_date( key )
        key.birth_date + convert_in_seconds( reset_key_after )
      end

    end
  end
end
