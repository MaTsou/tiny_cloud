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

      def build_temp_url( **context )
        return :unsupported unless supported?( **context )
        builder.call(**context)
      end

      def set_keys( keys )
        @keys = keys
      end

      def hooks_for( action, **context )
        return [] unless action == :temp_url
        res = supported?( **context ) ? hooks : []
        res << { result: -> (**options) { self.send(:build_temp_url, **options) } }
      end

      private

      def supported?( **context )
        context[:type] == :container
      end

      def push_key_to_builder
        builder.set_active_key keys[:active].value
      end

      def death_date( key )
        key.birth_date + convert_in_seconds( reset_key_after )
      end
    end
  end
end
