require_relative 'token_manager'
require_relative 'temp_url_manager'
require_relative 'configuration'

module TinyCloud
  module Openstack
    class Account
      include TinyCloud::Openstack::TokenManager

      attr_accessor :auth_token, :auth_token_birth
      attr_reader :temp_url_manager

      def initialize
        yield configuration
        @temp_url_manager = Openstack::TempUrlManager.new( self )
        # set an expired token birth to force renewing it !
        @auth_token_birth = now - 2 * convert_in_seconds(AUTH_TOKEN_LIFE_TIME)
      end

      def configuration
        @configuration ||= Openstack::Configuration.new
      end

      def header
        { 'X-Auth-Token' => auth_token }
      end

      def check_authentication
        return true if auth_token_life_period.include? now
        { action_needed: :renew_token, request: reset_auth_token_request }
      end

      def renew_token( response )
        # TODO manage response issues..
        @auth_token = response.headers['x-subject-token']
        @auth_token_birth = now
      end

      def method_missing( name, *args, **options )
        # used to delegate..
        case name
        when /temp_url/
          temp_url_manager.send( name, *args, **options )
        else
          super
        end
      end

      def now
        Time.now
      end

      def convert_in_seconds( hash )
        hash.reduce( 0 ) do |seconds, delay|
          case [delay].to_h
          in days:
            seconds += 86400 * days
          else
            seconds
          end
        end
      end
    end
  end
end
