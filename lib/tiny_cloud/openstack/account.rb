require_relative 'token_manager'
require_relative 'temp_url_manager'
require_relative 'configuration'
require_relative '../queue'

module TinyCloud
  module Openstack
    class Account

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

      def queue_for( action, storage, **options )
        context = options.merge( url: storage.url, type: storage.type )

        queue = TinyCloud::Queue.new( **context )

        queue.add token_manager.enqueue_hooks( **context )

        case action
        when :list, :add, :remove, :read
          queue.add request_for( action, **context )
        when :temp_url
          queue.add temp_url_manager.enqueue_building( **context )
        end
      end

      def request_for( action, **context )
        req = case action
        when :list
          { url: context[:url], method: :get }
        when :read
          { url: context[:url], path: context[:path], method: :get }
        end
        [
          request: TinyCloud::Request.new do
            { options: { headers: header } }.merge req
          end
        ]
      end

    end
  end
end
