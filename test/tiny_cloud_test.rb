require_relative 'test_helper'

Excon.defaults[:mock] = true

describe TinyCloud::Storage do

  URL = 'https://my_storage_url'
  AUTH_TOKEN = 'My wonderful auth token'

  before do
    @account = TinyCloud::Openstack::Account.new do |config|
      config.project_name = 'My_project_name'
      config.project_domain_name = 'default'
      config.project_id = 'My_project_id'
      config.root_url = ROOT_URL
      config.region_name = 'dc3-a'
      config.api_version = 'v3'
      config.user_name = 'My_user_name'
      config.user_domain_name = 'default'
      config.auth_url = 'https://this_is_auth_url'
      config.password = 'My_wonderful_and_unbreakable_pwv'
      config.temp_url_default_life_time = 300
      config.temp_url_key_reset_after = { days: 30 }
      config.auth_token_reset_after = { days: 30 }
    end

    @configuration = @account.configuration

    @storage = TinyCloud::Storage.new do |storage|
      storage.account = @account
      storage.url = URL

      @auth_url = [ @configuration.auth_url, "/auth/tokens" ].join
    end

    Excon.stub(
      { url: @auth_url, method: :post },
      { status: 200, headers: { 'x-subject-token' => AUTH_TOKEN } }
    )

  end

  it "correctly set auth_token" do
    Excon.stub( { method: :get }, {} )
    @storage.list
    _( @account.token_manager.auth_token ).must_equal AUTH_TOKEN
  end

  it "correctly build list request" do
    Excon.stub(
      { url: @storage.url, method: :get },
      { status: 200 }
    )
    @storage.list
  end

  it "correctly build read request" do
    skip
    path = 'my_path'

    @storage.read path
  end

  it "correctly build remove request" do
    skip
    path = 'my_path'

    @storage.remove path
  end

  it "correctly hook temp_url requests" do
    @container = @storage.call( 'container' )
    path = 'john'
    url = [ @container.url, path ].join('/')
    method = :get

    Excon.stub(
      { url: @container.url, method: method },
      {
        status: 200,
        headers: {
          'X-Container-Meta-Temp-Url-Key' => 'active',
          'X-Container-Meta-Temp-Url-Key-2' => 'inactive',
        }
      }
    )
    @storage.call( 'container' ).temp_url( path:, method: )
    _( @account.temp_url_manager.keys[:active].value ).must_equal 'active'
  end
end
