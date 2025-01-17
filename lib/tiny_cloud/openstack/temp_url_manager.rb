require 'json'
require_relative 'temp_url_builder'

module TinyCloud
  module Openstack
    class TempUrlManager
      TEMP_URL_KEY_LIFE_TIME = { days: 30 }
      TEMP_URL_LIFE_TIME = 300 # 5 minutes
      HEADER_NAMES = {
        # containers only then !
        first: "X-Container-Meta-Temp-URL-Key",
        second: "X-Container-Meta-Temp-URL-Key-2",
      }

      Key = Struct.new( :id, :header, :value, :birth_date )

      attr_accessor :account, :keys
      attr_reader :caller_url

      def initialize( account )
        @account = account
      end

      def build_temp_url( url:, method:, life_time:, prefix: )
        Openstack::TempUrlBuilder.new(
          root_url: account.configuration.root_url,
          url:, method:, life_time:, prefix:,
          active_temp_url_key: keys[:active].value,
        ).call
      end

      def check_temp_url_keys( caller_url )
        @caller_url = caller_url
        temp_url_keys_missing ||
          temp_url_keys_expired ||
          true
      end

      private

      def retrieves_temp_url_keys( response )
        ids = { first: :active, second: :other }

        case response
        in status2xx: response
          @keys = HEADER_NAMES.map do |k, v|
            [ k,
              Key.new(
                id: k,
                header: v,
                value: response.headers.fetch( v.downcase, nil ),
                birth_date: Time.now
              )
            ]
          end.to_h.transform_keys( ids )
        else end
      end

      def reset_temp_url_key( response )
        case response
        in status2xx:
          JSON.parse response.body
        else end # FIXME server error managment needed..
        # TODO to be continued
      end

      def retrieves_temp_url_keys_request
        {
          url: caller_url,
          method: :get,
          options: { headers: account.header }
        }
      end

      def reset_temp_url_key_request
      end

      def temp_url_keys_missing
        {
          action_needed: :retrieves_temp_url_keys,
          request: retrieves_temp_url_keys_request
        } unless keys
      end

      def temp_url_keys_expired
        {
          action_needed: :reset_temp_url_key,
          request: reset_temp_url_key_request
        } unless expired?( keys[:active] )
      end

      def expired?( key )
        # check if expire tomorrow
        key.birth_date.advance( TEMP_URL_KEY_LIFE_TIME ) < Date.today.succ
      end
    end
  end
end
