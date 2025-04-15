# frozen_string_literal: true

module TinyCloud
  # Action manager base class
  class ActionManager
    CONST_TYPE = {
      action: 'Actions',
      hook: 'Hooks'
    }.freeze

    def self.register_action(name)
      hooks = yield [] if block_given?
      define_method "hooks_for_#{name}" do
        hooks
      end
    end

    def initialize(holder, request_processor)
      @holder = holder
      @request_processor = request_processor
      @actions = {}
      @hooks = {}
    end

    def call(name, context)
      resolve(name) do |action, hooks|
        action.call(*hooks, @holder, @request_processor, context)
      end
    end

    private

    def resolve(name)
      res = get_action(name)
      yield res[:action], res[:hooks]
    end

    def get_action(name)
      @actions[name] ||= {
        action: to_const(name, :action).new,
        hooks: awake_hooks(name)
      }
    end

    def awake_hooks(name)
      send("hooks_for_#{name}")&.map do |hook|
        @hooks[hook] ||= to_const(hook, :hook).new
      end
    end

    def const(name)
      name.to_s.split('_').map(&:capitalize).join
    end

    def prefix
      self.class.to_s.gsub(/::\w*$/, '')
    end

    def to_const(name, type)
      Object.const_get(
        [prefix, CONST_TYPE[type], const(name)].join('::')
      )
    end
  end
end
