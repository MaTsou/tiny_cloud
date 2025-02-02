hooks = %w(
auth_token_expired_hook temp_url_key_missing_hook temp_url_key_expired_hook
)

hooks.each do |file|
  require_relative file
end

module TinyCloud
  module Openstack
    module Hooks

      def self.[]( hook )
        @@hooks ||= {}
        @@hooks[hook] ||= set_hook( hook )
      end

      def self.set_hook( hook )
        Object.const_get(
           [
             "TinyCloud::Openstack::",
             (hook.to_s + '_hook').split('_').map(&:capitalize).join
           ].join
        ).new
      end
    end
  end
end
