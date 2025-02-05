module TinyCloud
  class ActionManager
    def self.register_hook( name, object )
      @@lazy_hooks ||= {}
      @@lazy_hooks[name] ||= object
    end

    def self.register_action( name, object )
      @@lazy_actions ||= {}
      @@lazy_actions[ to_snake object ] = object
      @@action_hooks ||= {}
      @@action_hooks[ to_snake object ] = yield []
    end

    def initialize( holder, request_processor )
      @holder = holder
      @request_processor = request_processor
      @actions = {}
      @hooks = {}
    end

    def call( action, context )
      called = get_action( action )
      called[ :action ].call(
        *called[ :hooks ], @holder, @request_processor, context
      )
    end

    def get_action( action )
      @actions[ action ] ||= {
        action: @@lazy_actions[ action ].new,
        hooks: @@action_hooks[ action ]&.map { |h| @hooks[h] ||= @@lazy_hooks[h].new }
      }
    end

    def awake_hooks( action )
      @@action_hooks[ action ]&.map do |hook|
        @hooks[hook] ||= @@lazy_hooks[hook].new
      end
    end

    def self.to_action( str )
      str.to_s.split('::').last
    end

    def self.to_snake( str )
      to_action( str )
        .gsub( /([a-z]+)([A-Z])/, '\1_\2' )
        .downcase
        .to_sym
    end

  end
end
