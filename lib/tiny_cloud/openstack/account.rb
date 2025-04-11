# frozen_string_literal: true

module TinyCloud
  module Openstack
    # account class
    class Account
      attr_reader :temp_url_manager, :auth_manager, :action_manager

      def initialize(request_processor = TinyCloud::RequestProcessor.new)
        yield configuration
        @action_manager = Openstack::ActionManager.new(self, request_processor)

        @temp_url_manager = Openstack::TempUrlManager.new(configuration)
        @auth_manager = Openstack::AuthManager.new(configuration)
      end

      def configuration
        @configuration ||= Openstack::Configuration.new
      end

      def call(action, context)
        @action_manager.call(action, context)
      end
    end
  end
end
