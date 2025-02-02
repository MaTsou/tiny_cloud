module TinyCloud
  class Action < Module

    def self.inherited( klass )
      self.instance_eval do
        @@actions ||= {}
        @@actions[ to_snake klass ] ||= klass.new
      end

      klass.instance_eval do
        include ActionBase

        def register_hook( name, object )
          @@hooks ||= {}
          @@hooks[name] ||= object.new
        end

        def registered_actions( action )
          @@actions[ action ]
        end

      end

      klass.class_eval do
        def registered_hooks
          @@hooks
        end
      end
    end

    def self.to_action( str )
      str.to_s.split('::').last
    end

    def self.to_snake( str )
      to_action( str )
        .gsub( /([a-z]+)([A-Z])/, '\1_\2' )
        .downcase
        .to_sym
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
