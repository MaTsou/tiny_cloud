hooks = %w(
 auth_token_expiry_hook
 temp_url_key_missing_hook
 temp_url_key_expiry_hook
)

hooks.each do |h|
  require_relative h
end

module TinyCloud
  module Openstack
    class Action < TinyCloud::Action
      register :auth_token_expiry, TinyCloud::Openstack::AuthTokenExpiryHook
      register :temp_url_key_missing, TinyCloud::Openstack::TempUrlKeyMissingHook
      register :temp_url_key_expiry, TinyCloud::Openstack::TempUrlKeyExpiryHook
    end
  end
end
