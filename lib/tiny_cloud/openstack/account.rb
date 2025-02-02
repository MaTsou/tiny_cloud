%w( token_manager temp_url_manager configuration action ).each do |f|
  require_relative f
end

%w( list read temp_url ).each do |f|
  require_relative f
end

module TinyCloud
  module Openstack
    class Account
      attr_reader :temp_url_manager, :token_manager, :request_processor, :actions

      def initialize( request_processor = TinyCloud::RequestProcessor.new )
        yield configuration
        @request_processor = request_processor
        @actions = {}
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
        actions[ action ] ||= set_action( action )
      end

      def set_action( action )
        Object.const_get( get_hook_for action ).new
      end

      def get_hook_for( action )
        [ "TinyCloud::Openstack", suffix( action ) ].join('::')
      end

      def suffix( action )
        action.to_s.split('_').map(&:capitalize).join
      end
    end
  end
end
