module TinyCloud
  class RequestBuilder

    attr_reader :account, :request_formatter

    # Ne devrait pas avoir besoin de account.
    # le requête qu'il reçoit devrait contenir tout ce qu'il faut.
    def initialize( *account )
      @account = account&.first
      @request_formatter = Struct.new( :url, :method, :options )
    end

    def call( method:, **options )
      case options
      in url:, **rest
        formatted_request(
          url: [url, rest.delete(:path)].compact.join('/'),
          method: method,
          options: build_options( rest[:options] )
        )
      else
        raise KeyError, "A url is needed !"
      end
    end

    private

    def build_options( rest )
      default = { headers: account.header }
      return default unless rest
      rest
        .merge( rest&.delete(:headers) || {} )
        .merge( rest || {} )
    end

    def formatted_request( url:, method:, options: )
      request_formatter.new( url, method, options )
    end
  end
end
