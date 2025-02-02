%w( token_manager temp_url_manager configuration ).each do |f|
  require_relative f
end

%w( list read temp_url ).each do |f|
  require_relative f
end

module TinyCloud
  module Openstack
    class Account
      attr_reader :temp_url_manager, :token_manager, :request_processor, :actions

      def initialize( request_processor = nil )
        yield configuration
        @request_processor = request_processor || TinyCloud::RequestProcessor.new
        @actions = {}
        @temp_url_manager = Openstack::TempUrlManager.new( self )
        @token_manager = Openstack::TokenManager.new( self )
      end

      def configuration
        @configuration ||= Openstack::Configuration.new
      end

      def call( action_called, context )
        action( action_called )
          .call(*hooks_for( action_called ), self, context )
      end

      def header
        { 'X-Auth-Token' => token_manager.auth_token }
      end

      def set_active_key( key )
        action(:temp_url).set_active_key key
      end

      private

      def hooks_for( action )
        case action
        when :list, :read, :add, :remove
          token_manager.hooks
        when :temp_url
          token_manager.hooks.concat temp_url_manager.hooks
        end
      end

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
