module TinyCloud
  module Openstack
    class TempUrlBuilder
      attr_reader :root_url, :default_life_time, :active_key,
        :url, :method, :life_time, :prefix

      def initialize( configuration )
        @root_url = configuration.root_url
        @default_life_time = configuration.temp_url_default_life_time
      end

      def call( url:, method:, path: nil, life_time: nil, prefix: nil, **rest )
        @url = [ url, path ].compact.join('/')
        @method, @prefix = method, prefix
        @life_time = life_time || default_life_time

        return "#{@url}?#{query_args}" unless prefix
        -> (path) { "#{url}#{path}?#{query_args}" }
      end

      def set_active_key( key )
        @active_key = key
      end

      private

      def query_args
        [
          "temp_url_sig=#{sig}&temp_url_expires=#{expires}",
          ( "&temp_url_prefix=#{prefix}" if prefix )
        ].compact.join
      end

      def expires
        @expires ||= ( Time.now + life_time ).to_i
      end

      def sig
        digest = OpenSSL::Digest.new( 'sha256' )
        OpenSSL::HMAC.hexdigest( digest, active_key, my_data )
      end

      def my_data
        "#{method.to_s.upcase}\n#{expires}\n#{path}"
      end

      def path
        # prefixed paths do not work..
        [ ("prefix:" if prefix), url.gsub( root_url, '' ) ]
          .compact
          .join
      end

    end
  end
end
