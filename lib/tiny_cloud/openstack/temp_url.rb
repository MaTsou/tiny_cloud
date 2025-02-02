module TinyCloud
  module Openstack
    class TempUrl < TinyCloud::Hook
      include ActionHook, Hooks

      attr_reader :root_url, :url, :prefix, :life_time, :default_life_time

      def before_hooks
        chain(
          Hooks[:auth_token_expired],
          Hooks[:temp_url_key_missing],
          Hooks[:temp_url_key_expired]
        )
      end

      def supported?
        context.type == :container
      end

      def request
        @url = [ context.url, context.path ].compact.join('/')
        @prefix = context.prefix
        @life_time = context.life_time || configuration.temp_url_default_life_time

        return [ url, query_args ].join('?') unless prefix
        -> (path) { "#{url}#{path}?#{query_args}" }
      end

      def active_key
        temp_url_manager.active_key
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
        "#{context.method.to_s.upcase}\n#{expires}\n#{path}"
      end

      def path
        # prefixed paths do not work..
        [ ("prefix:" if prefix), url.gsub( configuration.root_url, '' ) ]
          .compact
          .join
      end

    end
  end
end
