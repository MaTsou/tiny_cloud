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

      warm_up( :check_authentication )

      # receiving a list of actions : method_missing( action, *args )
      # I need to delegate this to a RequestBuilder object.. It collects 
      # requests from a list and format them to be processed..
      #method = API[ action ]
      #request( args.map { |opt| request_builder.call( method: method, **opt ) } )
      request( method: API[ action ], **options )
    end

    def temp_url( caller_url:, url:, method:, life_time:, prefix: )
      warm_up( :check_authentication )
      warm_up( :check_temp_url_keys, caller_url )
      account.build_temp_url( url:, method:, life_time:, prefix: )
    end

    private

    def request( method:, **options )
      http_client.call( request_builder.call( method:, **options ) )
    end

    def warm_up( method_name, *args )
      case account.send( method_name, *args )
      in action_needed: action_name, **rest
        account.send( action_name, request( **rest[:request] )
        )
      else end
    end
  end
end
