require 'json'
require_relative 'temp_url_builder'
require_relative 'temp_url_key_missing_hook'
require_relative 'temp_url_key_expired_hook'

module TinyCloud
  module Openstack
    class TempUrlManager
      include TinyCloud::TimeCalculation

      attr_reader :account, :keys, :hooks, :caller_url,
        :builder, :reset_key_after

      def initialize( account )
        @account = account
        @reset_key_after = account.configuration.temp_url_key_reset_after
        @builder = Openstack::TempUrlBuilder.new( account.configuration )
        @hooks = [
          TinyCloud::Openstack::TempUrlKeyMissingHook.new( self ),
          TinyCloud::Openstack::TempUrlKeyExpiredHook.new( self ),
        ]
      end

      def build_temp_url( **options )
        builder.call **options
      end

      def set_keys( keys )
        @keys = keys
      end

      def enqueue_building( **context )
        return [ :unsupported ] unless context[:type] == :container

        enqueue_hooks( **context ).concat(
          [
            proc: -> (**options) { build_temp_url( **options ) }, **context
          ]
        )
      end

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
