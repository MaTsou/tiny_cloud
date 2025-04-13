# frozen_string_literal: true

require 'uri'

module TinyCloud
  # A tiny url manager
  class TinyUrl
    class << self
      # calling these to class methods leads to deep cloning...
      def add_to_path(tiny_url, *args)
        new(tiny_url).add_to_path(*args)
      end

      def add_to_query(tiny_url, **options)
        new(tiny_url).add_to_query(**options)
      end
    end

    attr_reader :origin

    def initialize(url)
      # passing url.to_s to URI.parse gives the opportunity to initialize a
      # TinyUrl given a TinyUrl : this is deep cloning...
      URI.parse(url.to_s).then do |uri|
        @origin = uri.origin
        @path = build_path uri.path
        @query = build_query uri.query
      end
    end

    def to_s
      @origin
        .then { |url| [url, path].compact.join }
        .then { |url| [url, query].select(&:itself).join('?') }
    end

    def path
      @path.join('/')
    end

    def query
      @query.any? && URI.encode_www_form(@query)
    end

    def add_to_path(*args)
      @path.concat args.join('/').split('/').reject(&:empty?)
      self
    end

    def add_to_query(**options)
      @query.merge! keys_to_sym(options) if options
      self
    end

    def ==(other)
      @origin == other.instance_variable_get(:@origin) &&
        path == other.send(:path) &&
        @query == other.instance_variable_get(:@query)
    end

    private

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
