module TinyCloud
  class RequestProcessor
    attr_accessor :http_client

    def initialize( http_client: nil )
      @http_client = http_client || TinyCloud::Excon::HttpClient.new
      yield self if block_given?
    end

    def call( step, context )
      execute step, **context
    end

    private

    def execute( hook, **options )
      case res = hook.call(**options)
      in action_needed: request
        hook.handle response_to( request, **options )
      else
      res
      end
    end

    def response_to( request, **options )
      http_client.call request.call(**options)
    end

  end
end
