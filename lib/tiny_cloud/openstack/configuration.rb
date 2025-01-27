module TinyCloud
  module Openstack
    class Configuration
      attr_accessor :project_name, :project_domain_name, :project_id,
        :root_url, :region_name, :api_version,
        :user_name, :user_domain_name, :auth_url, :password,
        :auth_token_reset_after, :temp_url_key_reset_after,
        :temp_url_default_life_time
    end
  end
end
