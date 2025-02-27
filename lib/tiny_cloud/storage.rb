module TinyCloud
  class Storage
    attr_accessor :account, :url, :type

    def initialize( account, url:, type: :storage )
      @account = account
      @url = url
      @type = type
      yield account.configuration if block_given?
    end

    def call( sub_storage_name )
      return unless type == :storage #  a single nested storage level (container)
      container = self.class.new(
        account,
        url: join_paths( url, sub_storage_name ),
        type: :container
      )
      block_given? ? yield( container ) : container
    end

    # delegation to account : building operation queues to be performed
    def method_missing( action, **options )
      account.call(
        action,
        Ustruct.new( options, url: self.url, type: self.type )
      )
    end

    private

    def join_paths( *paths )
      paths.compact.join( '/' )
    end
  end
end
