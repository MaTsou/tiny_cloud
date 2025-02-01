module TinyCloud
  class Hook
    attr_reader :holder, :request_processor, :context

    def initialize( holder, request_processor )
      @holder = holder
      @request_processor = request_processor
    end

    def supported?
      true
    end

    def needed?
      true
    end

    def call( *before_hooks, **options )
      @context = options
      return :unsupported unless supported?

      before_hooks.pop&.call( *before_hooks, **options )

      handle( request ) if needed?
    end

    def handle( response )
      response
    end

    # hooks decorates their holder
    def method_missing( meth, *args, **options )
      holder.send( meth, *args, **options )
    end

  end
end
