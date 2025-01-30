module TinyCloud
  class Storage
    attr_accessor :account, :url, :request_processor, :type

    def initialize( type = :storage )
      @type = type
      yield self
    end

    def call( sub_storage_name )
      return unless type == :storage #  a single nested storage level (container)
      self.class.new( :container ) do |container|
        container.account = account
        container.url = join_paths( url, sub_storage_name )
        container.request_processor = request_processor
      end
    end

    # delegation :
    # to account : building operation queues to be performed
    # to request_processor : to perform the queue
    def method_missing( name, **options )
      request_processor.call account.queue_for( name, self, **options )
    end

    private

    def join_paths( *paths )
      paths.compact.join( '/' )
    end
  end
end
