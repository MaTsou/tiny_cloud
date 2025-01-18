module TinyCloud
  class RequestBuilder

    attr_reader :account, :request_formatter

    def initialize( account )
      @account = account
      @request_formatter = Struct.new( :url, :method, :options )
    end

    def call( method:, **options )
      case options
      in url:, **rest
        formatted_request(
          url: url, method: method, options: build_options( rest[:options] )
        )
      else
        raise KeyError, "A url is needed !"
      end
    end

    private

    def build_options( rest )
      default = { headers: account.header }
      return default unless rest
      default
        .merge( rest&.delete(:headers) || {} )
        .merge( rest || {} )
    end

    def formatted_request( url:, method:, options: )
      request_formatter.new( url, method, options )
    end
  end
end
