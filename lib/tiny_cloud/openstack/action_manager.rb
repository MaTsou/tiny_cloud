module TinyCloud
  module Openstack
    class ActionManager < TinyCloud::ActionManager

      register_action :list do |hooks|
        hooks.push :auth_token_expiry
      end

      register_action :read do |hooks|
        hooks.push :auth_token_expiry
      end

      register_action :temp_url do |hooks|
        hooks.push :auth_token_expiry
        hooks.push :temp_url_key_missing
        hooks.push :temp_url_key_expiry
      end
    end
  end
end

