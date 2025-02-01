module TinyCloud
  class Hook
    attr_reader :holder

    def initialize( holder )
      @holder = holder
    end

    def needed?( **options )
      true
    end

    def call( **options )
      return true unless needed?( **options )
      {
        action_needed: TinyCloud::Request.new do |**context|
          request(**context)
        end
      }
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
