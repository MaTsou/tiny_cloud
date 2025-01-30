require_relative 'test_helper'

describe TinyCloud::Storage do
  F_ACCOUNT = 'my_fake_account'
  F_URL = 'my_fake_url'
  F_RP = 'my_fake_request_processor'
  D_TYPE = :storage # default type

  def klass
    TinyCloud::Storage
  end

  describe "instanciation" do
    def container_instance_test( storage, name )
    end

    it "returns correctly built instance" do
      storage = klass.new do |storage|
        storage.account = F_ACCOUNT
        storage.url = F_URL
        storage.request_processor = F_RP
      end
      _( storage.url ).must_equal F_URL
      _( storage.account ).must_equal F_ACCOUNT
      _( storage.request_processor ).must_equal F_RP
      _( storage.type ).must_equal D_TYPE
    end

    it "returns a container type storage on call" do
      name = 'my_container_name'
      storage = klass.new do |storage|
        storage.account = F_ACCOUNT
        storage.url = F_URL
        storage.request_processor = F_RP
      end
      container = storage.call( name )

      _( container.url ).must_equal [F_URL, name].join('/')
      _( container.account ).must_equal F_ACCOUNT
      _( container.request_processor ).must_equal F_RP
      _( container.type ).must_equal :container
    end
  end

  describe "usage" do

    before do
      @storage = klass.new do |s|
        s.url = F_URL
        s.account = Minitest::Mock.new
        s.request_processor= Minitest::Mock.new
      end
    end

    it "delegates methods to account, receiving queued operations" do
      options = { url: 'my_url', path: 'my_path', method: 'get' }
      queue = { a: 'wonder', ful: 'queue' }
      @storage.account.expect :queue_for, queue do |action, **args|
        args == options
      end
      @storage.request_processor.expect :call, true do |expected_queue|
        expected_queue == queue
      end

      @storage.list( **options )
      @storage.account.verify
      @storage.request_processor.verify
    end

  end
end
