# frozen_string_literal: true

module TinyCloud
  module Openstack
    module Actions
      # temp url action definition
      class TempUrl
        include TinyCloud::Chainable

        attr_reader :url, :prefix, :life_time

        def supported?
          context.type == :container
        end

        def request
          set_attributes
          set_query_args
          return url.to_s unless prefix

          ->(path) { url.add_to_path(path).to_s }
        end

        private

        def set_attributes
          @url = TinyUrl.new( context.url ).add_to_path(context.path)
          @prefix = context.prefix
          @life_time = context.life_time || temp_url_manager.default_life_time
        end

        def set_query_args
          url.add_to_query(temp_url_sig: sig, temp_url_expires: expires)
          url.add_to_query(temp_url_prefix: prefix) if prefix
        end

        def sig
          digest = OpenSSL::Digest.new('sha256')
          OpenSSL::HMAC.hexdigest(digest, active_key, my_data)
        end

        def active_key
          temp_url_manager.active_key.value
        end

        def my_data
          "#{http_method}\n#{expires}\n#{path}"
        end

        def http_method
          context.method.to_s.upcase
        end

        def expires
          (Time.now + life_time).to_i
        end

        def path
          # prefixed paths do not work..
          [('prefix:' if prefix), url.path].compact.join
        end
      end
    end
  end
end
