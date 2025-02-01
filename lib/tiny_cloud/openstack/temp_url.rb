module TinyCloud
  module Openstack
    class TempUrl < TinyCloud::Hook
      attr_reader :root_url, :default_life_time, :active_key,
        :url, :method, :life_time, :prefix

      def initialize( holder, request_processor )
        super
        @root_url = configuration.root_url
        @default_life_time = configuration.temp_url_default_life_time
      end

      def supported?
        context[:type] == :container
      end

      def request
        @url = [ context[:url], context[:path] ].compact.join('/')
        @method, @prefix = context[:method], context[:prefix]
        @life_time = context[:life_time] || default_life_time

        return [ url, query_args ].join('?') unless prefix
        -> (path) { "#{url}#{path}?#{query_args}" }
      end

      def set_active_key( key )
        @active_key = key
      end

      private

      def query_args
        [
          "temp_url_sig=#{sig}",
          "temp_url_expires=#{expires}",
          query_prefix
        ].compact.join('&')
      end

      def query_prefix
        "&temp_url_prefix=#{prefix}" if prefix
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
