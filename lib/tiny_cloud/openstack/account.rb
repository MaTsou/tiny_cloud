require_relative 'token_manager'
require_relative 'temp_url_manager'
require_relative 'configuration'

module TinyCloud
  module Openstack
    class Account

      attr_reader :temp_url_manager, :token_manager, :request_processor

      def initialize( request_processor = nil )
        yield configuration
        @temp_url_manager = Openstack::TempUrlManager.new( self )
        @token_manager = Openstack::TokenManager.new( self )
        @request_processor = request_processor || TinyCloud::RequestProcessor.new
      end

      def configuration
        @configuration ||= Openstack::Configuration.new
      end

      def call( action, storage, **options )
        context = options.merge( url: storage.url, type: storage.type )
        token_manager.hooks_for( action ).each do |hook|
          request_processor.call( hook.merge context )
        end
        temp_url_manager.hooks_for( action, **context )&.each do |hook|
          request_processor.call( hook.merge context )
        end
        request_processor.call( step_for( action ).call( **context ) )
      end

      def header
        { 'X-Auth-Token' => token_manager.auth_token }
      end

      def step_for( action )
        case action
        when :list, :add, :remove, :read
          -> (**context) {
            {  request: TinyCloud::Request.new do
              { options: { headers: header } }.merge(
                { url: context[:url], path: context[:path], method: :get }.compact
              )
            end }
          }
        when :temp_url
          -> ( **context ) { temp_url_manager.build_temp_url( **context ) }
        end
      end

    end
  end
end
