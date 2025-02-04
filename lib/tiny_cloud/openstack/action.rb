%w(
auth_token_expiry
temp_url_key_missing
temp_url_key_expiry
).each do |h|
  require_relative ["hooks", h].join('/')
end

module TinyCloud
  module Openstack
    class Action# < TinyCloud::Action
      extend ActionManager

      register_hook :auth_token_expiry, TinyCloud::Openstack::AuthTokenExpiry
      register_hook :temp_url_key_missing, TinyCloud::Openstack::TempUrlKeyMissing
      register_hook :temp_url_key_expiry, TinyCloud::Openstack::TempUrlKeyExpiry
    end
  end
end

