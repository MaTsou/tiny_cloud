require_relative 'test_helper'

describe TinyCloud::Storage do
  F_ACCOUNT = 'my_fake_account'
  F_URL = 'my_fake_url'
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
      end
      _( storage.url ).must_equal F_URL
      _( storage.account ).must_equal F_ACCOUNT
      _( storage.type ).must_equal D_TYPE
    end

    it "returns a container type storage on call" do
      name = 'my_container_name'
      storage = klass.new do |storage|
        storage.account = F_ACCOUNT
        storage.url = F_URL
      end
      container = storage.call( name )

      _( container.url ).must_equal [F_URL, name].join('/')
      _( container.account ).must_equal F_ACCOUNT
      _( container.type ).must_equal :container
    end
  end

  describe "usage" do

    before do
      @storage = klass.new do |s|
        s.url = F_URL
        s.account = Minitest::Mock.new
      end
    end

    it "delegates methods to account" do
      options = { path: 'my_path', method: 'get' }
      @storage.account.expect :call, true do |action, context|
        context.type == @storage.type &&
        context.url == @storage.url &&
        options.all? { |k,v| context[k] == v }
      end
      @storage.list( **options )
      @storage.account.verify
    end

  end
end
