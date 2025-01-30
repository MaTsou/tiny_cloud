module TinyCloud
  class Queue

    def initialize( **context )
      @context = context
      @queued = []
    end

    def add( steps )
      @queued.concat steps
    end

    def inspect
      @queued.map { |q| "#{q.keys.first} : #{q.values.first}" }
    end

    def reduce( default, &block )
      @queued.reduce( default ) do |result, step|
        block.call result, step
      end
    end
  end
end
