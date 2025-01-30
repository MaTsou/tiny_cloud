require_relative 'token_manager'
require_relative 'temp_url_manager'
require_relative 'configuration'

module TinyCloud
  module Openstack
    class Account

      attr_reader :temp_url_manager, :token_manager, :request_builder

      def initialize
        yield configuration
        @temp_url_manager = Openstack::TempUrlManager.new( self )
        @token_manager = Openstack::TokenManager.new( self )
        @request_builder = TinyCloud::RequestBuilder
      end

      def configuration
        @configuration ||= Openstack::Configuration.new
      end

      def header
        { 'X-Auth-Token' => token_manager.auth_token }
      end

      def queue_for( action, storage, **options )
        options.merge!( url: storage.url, type: storage.type )
        queue = [].concat to_queue( token_manager.hooks, **options )
        case action
        when :list, :add, :remove, :read
          queue.concat( request_for action, **options )
        when :temp_url
          queue.concat to_queue( temp_url_manager.hooks, **options )
          queue.concat [ proc: -> (**options) { temp_url_manager.build_temp_url( **options ) }, **options ]
        end
      end

      def to_queue( hooks, **options )
        hooks.reduce( [] ) do |queue, hook|
          queue.concat [{ hook: hook, **options }]
        end
      end

      # will become queue_for( ) and return queueing hooks and request..
      def hooks_for( action )
        case action
        when :read, :write, :erase
          token_manager.hooks
        when :temp_url
          token_manager.hooks.concat temp_url_manager.hooks
        end
      end

      def request_for( action, **options )
        case action
        when :list
          [ request: { url: options[:url], method: :get } ]
        when :read
          [ request: { url: options[:url], path: options[:path], method: :get } ]
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
