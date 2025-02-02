require_relative 'test_helper'

Excon.defaults[:mock] = true

describe TinyCloud::Storage do

  URL = 'https://my_storage_url'
  AUTH_TOKEN = 'My wonderful auth token'
  AUTH_TOKEN_EXPIRES_AT = Time.new( 2021, 10, 27, 12, 05, 07 )
  TUK = 'My first temp url key'
  TUK2 = 'My second temp url key'

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
    end

    @configuration = @account.configuration

    @storage = TinyCloud::Storage.new do |storage|
      storage.account = @account
      storage.url = URL

      @auth_url = [ @configuration.auth_url, "/auth/tokens" ].join
    end

    Excon.stub(
      { url: @auth_url, method: :post },
      {
        status: 200,
        headers: { 'x-subject-token' => AUTH_TOKEN },
        body: { token: { expires_at: AUTH_TOKEN_EXPIRES_AT.to_s } }.to_json
      }
    )

  end

  it "correctly set auth_token" do
    Excon.stub( { method: :get }, {} )
    @storage.list
    resulting = @account.token_manager
    _( resulting.auth_token ).must_equal AUTH_TOKEN
    _( resulting.auth_token_expires_at ).must_equal AUTH_TOKEN_EXPIRES_AT
  end

  it "correctly build list request" do
    Excon.stub(
      { url: @storage.url, method: :get },
      {}
    )
    @storage.list
  end

  it "correctly build read request on storage" do
    Excon.stub(
      { url: @storage.url, method: :get },
      {}
    )
    @storage.read
  end

  it "correctly build read request on container" do
    path = 'my_path'
    url = [ @storage.url, path ].join('/')
    Excon.stub(
      { url: url, method: :get },
      {}
    )
    @storage.read path: path
  end

  it "correctly build remove request" do
    skip
    path = 'my_path'

    @storage.remove path: path
  end

  describe :temp_url do
    before do
      @container = @storage.call( 'container' )
      @path = 'john'
      @url = [ @container.url, @path ].join('/')
      @method = :get

      Excon.stub(
        { url: @container.url, method: @method },
        {
          status: 200,
          headers: {
            'X-Container-Meta-Temp-Url-Key' => TUK,
            'X-Container-Meta-Temp-Url-Key-2' => TUK2,
          }
        }
      )
    end

    it "correctly hooks temp_url requests" do
      @storage.call( 'container' ).temp_url( path: @path, method: @method )
      keys = @account.temp_url_manager.keys

      _( keys.keys ).must_equal [ :active, :other ]
      _( keys.values.map(&:value) ).must_equal [ TUK, TUK2 ]
    end

    it "correctly build temp_url" do
      res = @storage.call( 'container' ).temp_url( path: @path, method: @method )
      _( res.split('?').first ).must_equal @url

      req_params = res.split('?').last.split('&').map { |r| r.split('=').first }
      _( req_params ).must_include(*[ 'temp_url_sig', 'temp_url_expires' ])
    end
  end
end
