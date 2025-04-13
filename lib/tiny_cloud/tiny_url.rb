# frozen_string_literal: true

require 'uri'

module TinyCloud
  # A tiny url manager
  class TinyUrl
    def initialize(str_url)
      URI.parse(str_url).then do |uri|
        @origin = uri.origin
        @path = build_path uri.path
        @query = build_query uri.query
      end
    end

    def to_s
      @origin
        .then { |url| [url, the_path].compact.join }
        .then { |url| [url, the_query].select(&:itself).join('?') }
    end

    def path
      the_path
    end

    def add_to_path(*args)
      @path.concat args.join('/').split('/').reject(&:empty?)
      self
    end

    def add_to_query(**options)
      @query.merge! keys_to_sym(options) if options
      self
    end

    private

    def the_path
      @path.join('/')
    end

    def the_query
      @query.any? && URI.encode_www_form(@query)
    end

    def build_path(uri_path)
      uri_path.empty? ? [''] : uri_path.split('/')
    end

    def build_query(uri_query)
      uri_query ? keys_to_sym(URI.decode_www_form(uri_query).to_h) : {}
    end

    def keys_to_sym(my_hash)
      my_hash.transform_keys(&:to_sym)
    end
  end
end
