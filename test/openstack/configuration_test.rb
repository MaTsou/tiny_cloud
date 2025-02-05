require_relative '../test_helper'
require_relative '../../lib/tiny_cloud/openstack/account'

describe TinyCloud::Openstack do
  ROOT_URL = "https://s3.pub1.infomaniak.cloud"
  STORAGE_URL = ROOT_URL + '/object/v1/AUTH/project_id'

  DEFAULT_CONFIG_CLASS = TinyCloud::Openstack::Configuration
  DEFAULT_HTTP_CLIENT = TinyCloud::Excon::HttpClient

  before do
    @auth = TinyCloud::Openstack::Account.new do |config|
      config.project_name = 'My_project_name'
      config.project_domain_name = 'default'
      config.project_id = 'My_project_id'
      config.root_url = ROOT_URL
      config.region_name = 'dc3-a'
      config.api_version = 'v3'
      config.user_name = 'My_user_name'
      config.user_domain_name = 'default'
      config.auth_url = 'This_is_auth_url'
      config.password = 'My_wonderful_and_unbreakable_pwv'
    end


    @storage = TinyCloud::Storage.new( @auth, url: STORAGE_URL ) do |config|
      config.temp_url_default_life_time = 300
      config.temp_url_key_reset_after = { days: 30 }
    end
  end

  it "correctly set config and instanciate default builders" do
    config = @storage.account.configuration
    _( config.class ).must_equal DEFAULT_CONFIG_CLASS
    _( config.root_url ).must_equal ROOT_URL
    _( config.is_a? DEFAULT_CONFIG_CLASS ).must_equal true
  end

end
