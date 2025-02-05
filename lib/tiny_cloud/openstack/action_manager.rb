%w(
auth_token_expiry
temp_url_key_missing
temp_url_key_expiry
).each do |h|
  require_relative ["hooks", h].join('/')
end

%w( list read temp_url ).each do |f|
  require_relative ["actions", f].join('/')
end

module TinyCloud
  module Openstack
    class ActionManager < TinyCloud::ActionManager

      register_hook :auth_token_expiry, TinyCloud::Openstack::AuthTokenExpiry
      register_hook :temp_url_key_missing, TinyCloud::Openstack::TempUrlKeyMissing
      register_hook :temp_url_key_expiry, TinyCloud::Openstack::TempUrlKeyExpiry

      register_action :list, TinyCloud::Openstack::List do |hooks|
        hooks.push :auth_token_expiry
      end

      register_action :read, TinyCloud::Openstack::Read do |hooks|
        hooks.push :auth_token_expiry
      end

      register_action :temp_url, TinyCloud::Openstack::TempUrl do |hooks|
        hooks.push :auth_token_expiry
        hooks.push :temp_url_key_missing
        hooks.push :temp_url_key_expiry
      end
    end
  end
end

