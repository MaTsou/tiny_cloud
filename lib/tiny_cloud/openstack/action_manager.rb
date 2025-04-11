# frozen_string_literal: true

module TinyCloud
  module Openstack
    # openstack action manager
    class ActionManager < TinyCloud::ActionManager
      register_action :list do |hooks|
        hooks.push :auth_token_expiry
      end

      register_action :read do |hooks|
        hooks.push :auth_token_expiry
      end

      register_action :upload do |hooks|
        hooks.push :auth_token_expiry
      end

      register_action :temp_url do |hooks|
        hooks.push :auth_token_expiry
        hooks.push :temp_url_key_missing
        hooks.push :temp_url_key_expiry
      end

      register_action :set_allowed_origins do |hooks|
        hooks.push :auth_token_expiry
      end

      register_action :set_exposed_headers do |hooks|
        hooks.push :auth_token_expiry
      end
    end
  end
end
