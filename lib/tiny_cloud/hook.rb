module TinyCloud
  # Hook.new( name, holder ) defines a 'name' named pre-request hook on 
  # holder.
  # holder is then expected to respond to
  # + a 'name?' boolean method stating for hook to be executed or not
  # + a 'name_request' method returning a request : { url:, method:, options: }
  # + a 'name_handling' method handling the request response..
  #
  class Hook
    attr_reader :holder

    def initialize( holder )
      @holder = holder
    end

    def call( *args, **options )
      return true unless needed?( *args, **options )
      {
        action_needed: the_request
      }
    end

    def the_request
      -> ( *args, **options ) do
        request *args, **options
      end
    end

    # hooks decorates their holder
    def method_missing( meth, *args, **options )
      holder.send( meth, *args, **options )
    end
    #def handle( response )
    #  holder.send( "#{name}_handling", response )
    #end
  end
end
