module TinyCloud
  class Request

    attr_reader :request_formatter

    def initialize( &block )
      @block = block
      @request_formatter = Struct.new( :url, :method, :options )
    end

    def call( **options )
      formatted_request(**@block.call(**options))
    end

    def formatted_request( **context )
      request_formatter.new(
        get_url( context ),
        context[:method],
        context[:options]
      )
    end

    private

    def get_url( context )
      join_paths context[:url], context[:path]
    end

    def join_paths( *paths )
      paths.compact.join( '/' )
    end

  end
end
