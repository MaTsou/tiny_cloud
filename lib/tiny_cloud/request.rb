module TinyCloud
  class Request

    attr_reader :request_formatter

    def initialize
      @request_formatter = Struct.new( :url, :method, :options )
    end

    def call( request )
      formatted_request( request )
    end

    def formatted_request( request )
      request_formatter.new(
        get_url( request ),
        request[:method],
        request[:options]
      )
    end

    private

    def get_url( request )
      join_paths request[:url], request[:path]
    end

    def join_paths( *paths )
      paths.compact.join( '/' )
    end

  end
end
