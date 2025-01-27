module TinyCloud
  # Hook.new( name, holder ) defines a 'name' named pre-request hook on 
  # holder.
  # holder is then expected to respond to
  # + a 'name?' boolean method stating for hook to be executed or not
  # + a 'name_request' method returning a request : { url:, method:, options: }
  # + a 'name_handling' method handling the request response..
  #
  class Hook
    attr_reader :name, :holder

    def initialize( name, holder )
      @name = name
      @holder = holder
    end

    def call( *args, **options )
      return true unless holder.send( "#{name}?", *args, **options )
      {
        action_needed: request( name )
      }
    end

    def request( name )
      -> ( *args, **options ) do
        holder.send "#{name}_request", *args, **options
      end
    end

    def handle( response )
      holder.send( "#{name}_handling", response )
    end
  end
end
