require_relative 'test_helper'

describe TinyCloud::Storage do
  F_URL = 'my_fake_url'
  F_RP = 'my_fake_request_processor'
  D_TYPE = :storage # default type

  def klass
    TinyCloud::Storage
  end

  describe "instanciation" do
    def storage_instance_test( storage )
      _( storage.url ).must_equal F_URL
      _( storage.request_processor ).must_equal F_RP
      _( storage.type ).must_equal D_TYPE
    end

    def container_instance_test( storage, name )
      _( storage.url ).must_equal [F_URL, name].join('/')
      _( storage.request_processor ).must_equal F_RP
    end

    it "returns correctly built instance on block_given?" do
      storage = klass.new do |storage|
        storage.url = F_URL
        storage.request_processor = F_RP
      end
      storage_instance_test( storage )
    end

    it "returns correctly built instance on args given" do
      storage = klass.new( url: F_URL, request_processor: F_RP )
      storage_instance_test( storage )
    end

    it "returns correctly built instance on mixed way" do
      storage = klass.new( url: F_URL ) do |storage|
        storage.request_processor = F_RP
      end
      storage_instance_test( storage )
    end

    it "returns a container type storage on call" do
      name = 'my_container_name'
      container = klass.new( url: F_URL, request_processor: F_RP )
        .call( name )
      container_instance_test( container, name )
      _( container.type ).must_equal :container
    end
  end

  describe "usage" do

    API = %i( add remove read )
    RP_API = %i( write erase read )

    before do
      @storage = klass.new( url: F_URL, request_processor: Minitest::Mock.new )
    end

    it "delegates API methods to request_processor" do
      RP_API.each do |method_name|
        @storage.request_processor.expect method_name, true do |**args|
          args.keys.include? :url
        end
      end

      API.each do |method_name|
        @storage.send( method_name, "my_arg" )
      end
      @storage.request_processor.verify
    end

    it "does not delegate temp_url if not container type storage" do
      _(
        @storage.temp_url( 'path', method: :get, life_time: 300 )
      ).must_equal :unsupported
    end

    it "delegates temp_url to request_processor when container type storage" do
      cont_name = 'my_container_name'
      path = 'my_path'
      container = @storage.call( cont_name )

      container.request_processor.expect :temp_url, :delegated do |**args|
        args.include? :url
        args[:url] == [ container.url, path ].join('/')
      end
      _(
        container.temp_url( path, method: :get, life_time: 300 )
      ).must_equal :delegated
      container.request_processor.verify
    end
  end
end
