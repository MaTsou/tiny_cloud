# frozen_string_literal: true

require 'ustruct'
require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

module TinyCloud
  class Error < StandardError; end
  # Your code goes here...
end
