%w( token_manager temp_url_manager configuration ).each do |f|
  require_relative f
end

%w( list read ).each do |f|
  require_relative f
end

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

      def call( action, context )
        context = context.to_hash
        queue = token_manager.hooks_for( action )

        queue.concat step_for( action, **context )

        queue.compact.reduce( :unsupported ) do |*, hook|
          case hook
          in result:
            result.respond_to?(:call) ? result.call(**context) : result
          else
            request_processor.call( hook, context )
          end
        end
      end

      def header
        { 'X-Auth-Token' => token_manager.auth_token }
      end

      def step_for( action, **context )
        case action
        when :list, :add, :remove, :read
          [
            Object.const_get(
              [ "TinyCloud::Openstack",
                action.to_s.split('_').map(&:capitalize).join
              ].join('::')
            ).new( self )
          ]
        when :temp_url
          temp_url_manager.hooks_for( action, **context )
        end
      end

    end
  end
end
