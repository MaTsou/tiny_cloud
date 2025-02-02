module TinyCloud
  class Action < Module

    def self.inherited( klass )
      klass.instance_eval do
        include ActionBase

        def register( name, object )
          @@hooks ||= {}
          @@hooks[name] ||= object.new
        end
      end

      klass.class_eval do
        def registered_hooks
          @@hooks
        end
      end
    end

  end

  module CommonHook
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

  module ActionBase
    include CommonHook

    # overriding call method
    def call( holder, context )
      @holder = holder
      super( *_before_hooks, holder, context )
    end

    def _before_hooks
      respond_to?(:before_hooks) ? before_hooks : []
    end

  end

  class Hook
    include CommonHook
  end
end
