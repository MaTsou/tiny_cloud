module TinyCloud
  class RequestProcessor
    API = {
      read: :get,
      write: :put,
      erase: :delete
    }

    attr_accessor :http_client, :account, :request_formatter

    def initialize( http_client: nil, account: nil )
      @http_client = http_client
      @account = account
      yield self if block_given?
      @request_formatter = Struct.new( :url, :method, :options )
    end

    def method_missing( action, **options )
      return super unless API.keys.include? action

      warm_up( :check_authentication )

      case options
      in url: url, **rest
        formatted_request(
          url: url, method: API[ action ], options: build_options( action, rest )
        )
      else
        raise KeyError, "A url is needed !"
      end
    end

    def temp_url( url, prefix )
      warm_up( :check_authentication )
      warm_up( :check_temp_url_keys, url )
      account.build_temp_url( url, prefix )
    end

    private

    def build_options( action, rest )
      { body: rest[:object] }
        .compact
        .merge( header: account.header )
    end

    def formatted_request( url:, method:, options: )
      http_client.call( request_formatter.new( url, method, options ) )
    end

    def warm_up( method_name, *args )
      case account.send( method_name, *args )
      in action_needed: action_name, **rest
        account.send(
          action_name, formatted_request( **rest[:request] )
        )
      else end
    end
  end
end
