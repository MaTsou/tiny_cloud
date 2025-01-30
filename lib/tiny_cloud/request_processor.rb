module TinyCloud
  class RequestProcessor
    API = {
      read: :get,
      write: :put,
      erase: :delete
    }

    attr_accessor :http_client, :account, :request_builder

    def initialize( http_client: nil, account: nil )
      @http_client = http_client
      @account = account
      yield self if block_given?
      @request_builder = TinyCloud::RequestBuilder.new( @account )
    end

    def call( queue )
      queue.reduce( :unsupported ) do |result, step|

        case step
        in hook:, **options
          execute hook, **options

        in proc:, **options
          proc.call **options

        in request:
          the_response_to request

        in requests:
          # not what I want. I want a permanent connection
          requests.each do |request|
            the_response_to request
          end
        else end
      end
    end

    private

    def execute( hook, **options )
      case hook.send( :call, **options )
      in action_needed: request
        hook.handle( send( :response_to, **( request.call **options ) ) )
      else end
    end

    def the_response_to( request, **options )
      response_to **request.merge( **options )
    end

    def response_to( **options )
      http_client.call( request_builder.call( **options ) )
    end

  end
end
