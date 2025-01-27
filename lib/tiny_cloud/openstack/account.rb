require_relative 'token_manager'
require_relative 'temp_url_manager'
require_relative 'configuration'

module TinyCloud
  module Openstack
    class Account
      include TinyCloud::TimeCalculation

      attr_reader :temp_url_manager, :token_manager

      def initialize
        yield configuration
        @temp_url_manager = Openstack::TempUrlManager.new( self )
        @token_manager = Openstack::TokenManager.new( self )
      end

      def configuration
        @configuration ||= Openstack::Configuration.new
      end

      def header
        { 'X-Auth-Token' => token_manager.auth_token }
      end

      def hooks_for( action )
        case action
        when :read, :write, :erase
          token_manager.hooks
        when :temp_url
          token_manager.hooks.concat temp_url_manager.hooks
        end
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
    end
  end
end
