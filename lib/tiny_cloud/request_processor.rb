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

    def method_missing( action, **options )
      return super unless API.keys.include? action

      lets_warm_up( action, **options )

      response_to( method: API[ action ], **options )
    end

    def temp_url( **options )
      lets_warm_up( :temp_url, **options )
      account.build_temp_url( **options )
    end

    private

    def response_to( **options )
      http_client.call( request_builder.call( **options ) )
    end

    def lets_warm_up( action, **options )
      account.warms_up_for( action ).each do |warm_up|
        case warm_up.call( **options )
        in action_needed: request
          warm_up.handle(
            response_to **(request.call **options )
          )
        else end
      end
    end
  end
end
