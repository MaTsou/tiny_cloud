%w( token_manager temp_url_manager configuration action_manager ).each do |f|
  require_relative f
end

module TinyCloud
  module Openstack
    class Account
      attr_reader :temp_url_manager, :token_manager, :action_manager

      def initialize( request_processor = TinyCloud::RequestProcessor.new )
        yield configuration
        @action_manager = Openstack::ActionManager.new( self, request_processor )
        @temp_url_manager = Openstack::TempUrlManager.new(
          reset_key_after: configuration.temp_url_key_reset_after
        )
        @token_manager = Openstack::TokenManager.new
      end

      def configuration
        @configuration ||= Openstack::Configuration.new
      end

      def call( action, context )
        @action_manager.call( action, context )
      end

      def header
        { 'X-Auth-Token' => token_manager.auth_token }
      end

    end
  end
end
