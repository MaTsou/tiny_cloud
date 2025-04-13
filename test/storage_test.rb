# frozen_string_literal: true

require_relative 'test_helper'

F_ACCOUNT = 'my_fake_account'
F_URL = 'http://my_fake_url'
D_TYPE = :storage # default type

describe TinyCloud::Storage do
  def klass
    TinyCloud::Storage
  end

  describe 'instanciation' do
    it 'returns correctly built instance' do
      storage = klass.new(F_ACCOUNT, url: F_URL)
      _(storage.url.to_s).must_equal F_URL
      _(storage.account).must_equal F_ACCOUNT
      _(storage.type).must_equal D_TYPE
    end

    it 'returns a container type storage on call' do
      name = 'my_container_name'
      storage = klass.new(F_ACCOUNT, url: F_URL)
      container = storage.call(name)

      _(container.url.to_s).must_equal [F_URL, name].join('/')
      _(container.account).must_equal F_ACCOUNT
      _(container.type).must_equal :container
    end
  end

  describe 'usage' do
    before do
      @storage = klass.new(Minitest::Mock.new, url: F_URL)
    end

    it 'delegates methods to account' do
      options = { path: 'my_path', method: 'get' }
      @storage.account.expect :call, true do |_action, context|
        context.type == @storage.type &&
          context.url == @storage.url &&
          options.all? { |k, v| context[k] == v }
      end
      @storage.list(**options)
      @storage.account.verify
    end
  end
end
