require_relative 'test_helper'

describe TinyCloud::Storage do
  URL = 'my_storage_url'
  AUTH_TOKEN_KEY = 'X-Auth-Token'

  before do
    @storage = TinyCloud::Storage.new do |storage|
      storage.url = URL
      storage.request_processor = TinyCloud::RequestProcessor.new(
        account: Minitest::Mock.new,
        http_client: Minitest::Mock.new
      )
    end
    @storage.request_processor.account.expect :header, { AUTH_TOKEN_KEY => nil }
  end

  it "correctly build list request" do
    @storage.request_processor.http_client.expect :call, true do |request|
      request.url = @storage.url
      request.method = :get
      request.options.keys.include? :header
      request.options[:header].keys.include? AUTH_TOKEN_KEY
    end

    @storage.request_processor.stub :warm_up, true do
      @storage.list
    end
    @storage.request_processor.http_client.verify
  end

  it "correctly build read request" do
    path = 'my_path'
    @storage.request_processor.http_client.expect :call, true do |request|
      request.url = [ @storage.url, path ].join('/')
      request.method = :get
      request.options.keys.include? :header
      request.options[:header].keys.include? AUTH_TOKEN_KEY
    end

    @storage.request_processor.stub :warm_up, true do
      @storage.read path
    end
    @storage.request_processor.http_client.verify
  end

  it "correctly build remove request" do
    path = 'my_path'
    @storage.request_processor.http_client.expect :call, true do |request|
      request.url = [ @storage.url, path ].join('/')
      request.method = :delete
      request.options.keys.include? :header
      request.options[:header].keys.include? AUTH_TOKEN_KEY
    end

    @storage.request_processor.stub :warm_up, true do
      @storage.remove path
    end
    @storage.request_processor.http_client.verify
  end
end
