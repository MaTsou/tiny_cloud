hooks = %w(
 auth_token_expiry
 temp_url_key_missing
 temp_url_key_expiry
)

hooks.each do |h|
  require_relative ["hooks", h].join('/')
end

module TinyCloud
  module Openstack
    class Action < TinyCloud::Action
      register :auth_token_expiry, TinyCloud::Openstack::AuthTokenExpiry
      register :temp_url_key_missing, TinyCloud::Openstack::TempUrlKeyMissing
      register :temp_url_key_expiry, TinyCloud::Openstack::TempUrlKeyExpiry
    end
  end
end
