module TinyCloud
  class Storage
    attr_accessor :account, :url, :type

    def initialize( type = :storage )
      @type = type
      yield self
    end

    def call( sub_storage_name )
      return unless type == :storage #  a single nested storage level (container)
      self.class.new( :container ) do |container|
        container.account = account
        container.url = join_paths( url, sub_storage_name )
      end
    end

    # delegation to account : building operation queues to be performed
    def method_missing( action, **options )
      account.call( action, self, **options )
    end

    private

    def join_paths( *paths )
      paths.compact.join( '/' )
    end
  end
end
