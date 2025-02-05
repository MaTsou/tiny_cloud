module TinyCloud
  module Chainable
    attr_reader :holder, :request_processor, :context

    def supported?
      true
    end

    def needed?
      true
    end

    def call( *before_hooks, holder, request_processor, context )
      @holder = holder
      @request_processor = request_processor
      @context = context
      return :unsupported unless supported?

      before_hooks.pop&.call( *before_hooks, holder, request_processor, context )

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
