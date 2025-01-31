module TinyCloud
  class RequestProcessor
    attr_accessor :http_client

    def initialize( http_client: nil )
      @http_client = http_client
      yield self if block_given?
    end

    def call( step )
      case step
      in hook:, **context
        execute hook, **context

      in request:, **context
        response_to request, **context

      in requests:
        :to_be_implemented# TODO
      else
        step
      end
    end

    private

    def execute( hook, **options )
      case hook.call( **options )
      in action_needed: request, **options
        hook.handle response_to( request, **options )
      else end
    end

    def response_to( request, **options )
      http_client.call request.call( **options )
    end

  end
end
