%w( token_manager temp_url_manager configuration action ).each do |f|
  require_relative f
end

%w( list read temp_url ).each do |f|
  require_relative ["actions", f].join('/')
end

module TinyCloud
  module Openstack
    class Account
      attr_reader :temp_url_manager, :token_manager, :request_processor

      def initialize( request_processor = TinyCloud::RequestProcessor.new )
        yield configuration
        @action_manager = Action.new
        @request_processor = request_processor
        @temp_url_manager = Openstack::TempUrlManager.new(
          reset_key_after: configuration.temp_url_key_reset_after
        )
        @token_manager = Openstack::TokenManager.new
      end

      def configuration
        @configuration ||= Openstack::Configuration.new
      end

      def call( action_called, context )
        action( action_called ).call( self, context )
      end

      def header
        { 'X-Auth-Token' => token_manager.auth_token }
      end

      private

      def action( action )
        #Action.registered_action( action )
        @action_manager.registered_action action
      end
    end
  end
end
