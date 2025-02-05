module TinyCloud
  module Openstack
    class ActionManager < TinyCloud::ActionManager

      register_hook :auth_token_expiry, Hooks::AuthTokenExpiry
      register_hook :temp_url_key_missing, Hooks::TempUrlKeyMissing
      register_hook :temp_url_key_expiry, Hooks::TempUrlKeyExpiry

      register_action :list, Actions::List do |hooks|
        hooks.push :auth_token_expiry
      end

      register_action :read, Actions::Read do |hooks|
        hooks.push :auth_token_expiry
      end

      register_action :temp_url, Actions::TempUrl do |hooks|
        hooks.push :auth_token_expiry
        hooks.push :temp_url_key_missing
        hooks.push :temp_url_key_expiry
      end
    end
  end
end

