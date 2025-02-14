module TinyCloud
  class ActionManager
    def self.register_action( name )
      @@action_hooks ||= {}
      @@action_hooks[ name ] = yield [] if block_given?
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
        action: to_action_const( action ).new,
        hooks: awake_hooks( action )
      }
    end

    def awake_hooks( action )
      @@action_hooks[ action ]&.map do |hook|
        @hooks[hook] ||= to_hook_const( hook ).new
      end
    end

    def to_const( name )
      name.to_s.split('_').map(&:capitalize).join
    end

    def prefix
      self.class.to_s.gsub( /::[A-Z,a-z,0-9]*$/, '' )
    end

    def to_action_const( name )
      Object.const_get( [ prefix, "Actions", to_const( name ) ].join('::') )
    end

    def to_hook_const( name )
      Object.const_get( [ prefix, "Hooks", to_const( name ) ].join('::') )
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
