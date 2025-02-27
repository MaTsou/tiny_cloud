require 'json'
require 'securerandom'

module TinyCloud
  module Openstack
    class TempUrlManager
      include TinyCloud::TimeCalculation

      Key = Struct.new( 'Key', :header, :value, :death_date ) do
        include TinyCloud::TimeCalculation

        def nil?
          value.nil?
        end

        def expired?
          death_date < Time.now
        end

        def nil_or_expired?
          nil? || expired?
        end

        def build_value( status )
          return generate if status == :active || nil?
          value
        end

        private

        def generate
          "Unbreakable-#{SecureRandom.alphanumeric}-Temp_Url_Key"
        end

      end

      attr_reader :keys

      def initialize( config )
        @config = config
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

      def active_key
        keys[:active]
      end

      def set_keys( keys )
        statuses = %i( active other )

        @keys = keys.map do |header, key|
          [
            statuses.shift,
            Key.new(
              header: header,
              value: key,
              death_date: Time.now + reset_key_after
            )
          ]
        end.to_h
      end

      def permute_keys
        @keys.transform_keys!( active: :other, other: :active )
      end

    end
  end
end
