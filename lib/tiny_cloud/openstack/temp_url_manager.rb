require 'json'
require_relative 'temp_url_key_missing_hook'
require_relative 'temp_url_key_expired_hook'

module TinyCloud
  module Openstack
    class TempUrlManager
      include TinyCloud::TimeCalculation

      attr_reader :account, :keys, :hooks, :reset_key_after

      def initialize( account )
        @account = account
        @reset_key_after = account.configuration.temp_url_key_reset_after
        @hooks = [
          TinyCloud::Openstack::TempUrlKeyMissingHook.new(
            self, account.request_processor
          ),
          TinyCloud::Openstack::TempUrlKeyExpiredHook.new(
            self, account.request_processor
          ),
        ]
      end

      def set_keys( keys )
        @keys = keys
      end

      private


      def push_key_to_builder
        account.set_active_key keys[:active].value
      end

      def death_date( key )
        key.birth_date + convert_in_seconds( reset_key_after )
      end
    end
  end
end
