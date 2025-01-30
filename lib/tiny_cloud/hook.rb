module TinyCloud
  class Hook
    attr_reader :holder

    def initialize( holder )
      @holder = holder
      holder.define_singleton_method :enqueue_hooks do |**context|
        hooks.map do |hook|
          { hook: hook, **context }
        end
      end
    end

    def call( *args, **options )
      return true unless needed?( *args, **options )
      {
        action_needed: the_request,
      }.merge options
    end

    def the_request
      TinyCloud::Request.new do |**context|
        request **context
      end
    end

    # hooks decorates their holder
    def method_missing( meth, *args, **options )
      holder.send( meth, *args, **options )
    end

  end
end
