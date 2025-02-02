module TinyCloud
  module ActionHook

    def call( holder, context )
      @holder = holder
      super( *before_hooks, holder, context )
    end

    def chain( *args )
      Array.new.concat(args)
    end

    def before_hooks
      []
    end
  end
end
