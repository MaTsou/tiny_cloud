module TinyCloud
  class Storage
    attr_accessor :url, :request_processor, :type

    def initialize( url: nil, request_processor: nil, type: :storage )
      @url = url
      @request_processor = request_processor
      @type = type
      yield self if block_given?
    end

    def call( sub_storage_name )
      return unless type == :storage #  a single nested storage (container)
      self.class.new(
        url: join_paths( url, sub_storage_name ),
        request_processor:,
        type: :container
      )
    end

    def list
      request_processor.read url: url
    end

    # add( single_path, single_object )
    # TODO add this syntax
    # add( [ first_path, first_object ], [ second_path, second_object ] )
    def add( path, object = nil )
      request_processor.write url: join_paths( url, path ), object: object
    end

    # remove( single_path, single_object )
    # TODO add this syntax
    # remove( [ first_path, first_object ], [ second_path, second_object ] )
    def remove( path )
      request_processor.erase url: join_paths( url, path )
    end

    # read( single_path, single_object )
    # TODO add this syntax
    # adread [ first_path, first_object ], [ second_path, second_object ] )
    def read( path )
      request_processor.read url: join_paths( url, path )
    end

    def temp_url( path, life_time:, method:, prefix: nil )
      # may be an Openstack only thing ?!
      return :unsupported unless type == :container
      request_processor.temp_url(
        caller_url: url,
        url: join_paths( url, path ),
        method: method,
        life_time: life_time,
        prefix: prefix
      )
    end

    private

    def join_paths( *paths )
      paths.compact.join( '/' )
    end
  end
end
