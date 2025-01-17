module TinyCloud
  module Openstack
    class TempUrlBuilder
      attr_reader :root_url, :active_key, :url,
        :method, :life_time, :prefix

      def initialize( root_url:, active_temp_url_key:,
                     url:, method:, life_time:, prefix: )
        @root_url = root_url
        @active_key = active_temp_url_key
        @url = url
        @method = method
        @life_time = life_time
        @prefix = prefix
      end

      def call
        "#{url}?temp_url_sig=#{sig}&temp_url_expires=#{expires}"
      end

      private

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
        url.gsub( root_url, '' )
      end
    end
  end
end
