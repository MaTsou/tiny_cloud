hooks = %w(
 auth_token_expired_hook
 temp_url_key_missing_hook
 temp_url_key_expired_hook
)

hooks.each do |h|
  require_relative h
end

module TinyCloud
  module Openstack
    class Action < TinyCloud::Action
      register :auth_token_expiry, TinyCloud::Openstack::AuthTokenExpiredHook
      register :temp_url_key_missing, TinyCloud::Openstack::TempUrlKeyMissingHook
      register :temp_url_key_expiry, TinyCloud::Openstack::TempUrlKeyExpiredHook
    end
  end
end
