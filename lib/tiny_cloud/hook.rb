module TinyCloud
  class Hook
    attr_reader :holder, :context

    def supported?
      true
    end

    def needed?
      true
    end

    def call( *before_hooks, holder, context )
      @holder = holder
      @context = context
      return :unsupported unless supported?

      before_hooks.pop&.call( *before_hooks, holder, context )

      handle( request ) if needed?
    end

    def handle( response )
      response
    end

    # hooks decorates their holder (actually an account)
    def method_missing( meth, *args, **options )
      holder.send( meth, *args, **options )
    end

  end
end
