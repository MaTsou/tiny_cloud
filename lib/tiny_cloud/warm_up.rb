module TinyCloud
  class WarmUp
    attr_reader :name, :calling_object

    def initialize( name, calling_object )
      @name = name
      @calling_object = calling_object
    end

    def call( *args, **options )
      return true unless calling_object.send( "#{name}?", *args, **options )
      {
        action_needed: request( name )
      }
    end

    def request( name )
      -> ( *args, **options ) do
        calling_object.send "#{name}_request", *args, **options
      end
    end

    def handle( response )
      calling_object.send( "#{name}_handling", response )
    end
  end
end
